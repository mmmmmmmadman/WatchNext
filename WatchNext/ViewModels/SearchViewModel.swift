import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
class SearchViewModel {
    static let favoritesGenre = Genre(id: -1, name: "Favorites")

    var movies: [Movie] = []
    var tvShows: [TVShow] = []
    var isLoading = false
    var errorMessage: String?
    var currentPage = 1
    var totalPages = 1
    var hasMorePages: Bool { currentPage < totalPages && selectedGenre?.id != SearchViewModel.favoritesGenre.id }

    var selectedContentType: ContentType = .movies
    var selectedGenre: Genre?
    var selectedSortOption: SortOption = .popularityDesc
    var minYear: Int?
    var maxYear: Int?
    var minRating: Double?

    var movieGenres: [Genre] = []
    var tvGenres: [Genre] = []

    /// 各 provider 支援的地區，啟動時載入一次
    var providerRegions: [Int: Set<String>] = [:]

    var currentGenres: [Genre] {
        selectedContentType == .movies ? movieGenres : tvGenres
    }

    /// 根據當前平台過濾可用地區（取平台所有 provider ID 的聯集）
    func availableRegions(for platformId: String) -> [(code: String, name: String)] {
        guard let platform = Constants.TMDB.StreamingPlatform.find(by: platformId) else {
            return Constants.TMDB.Region.availableRegions
        }

        // 如果 providerRegions 尚未載入，顯示全部地區
        guard !providerRegions.isEmpty else {
            return Constants.TMDB.Region.availableRegions
        }

        // 取該平台所有 provider ID 支援地區的聯集
        var supportedCodes = Set<String>()
        for providerId in platform.providerIds {
            if let regions = providerRegions[providerId] {
                supportedCodes.formUnion(regions)
            }
        }

        return Constants.TMDB.Region.availableRegions.filter { supportedCodes.contains($0.code) }
    }

    private let tmdbService = TMDBService()
    private let omdbService = OMDbService()
    private var cacheService: CacheService?
    private(set) var favoritesViewModel: FavoritesViewModel?

    func setCacheService(_ service: CacheService) {
        self.cacheService = service
    }

    func setFavoritesViewModel(_ viewModel: FavoritesViewModel) {
        self.favoritesViewModel = viewModel
    }

    func loadGenres() async {
        do {
            async let movieGenresTask = tmdbService.getMovieGenres()
            async let tvGenresTask = tmdbService.getTVGenres()
            async let providerRegionsTask = tmdbService.fetchProviderRegions()

            var fetchedMovieGenres = try await movieGenresTask
            var fetchedTVGenres = try await tvGenresTask

            // Provider 地區資料載入失敗不阻擋整體流程
            if let fetchedProviderRegions = try? await providerRegionsTask {
                providerRegions = fetchedProviderRegions
            }

            // Add Favorites at the beginning
            fetchedMovieGenres.insert(SearchViewModel.favoritesGenre, at: 0)
            fetchedTVGenres.insert(SearchViewModel.favoritesGenre, at: 0)

            movieGenres = fetchedMovieGenres
            tvGenres = fetchedTVGenres
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func discover() async {
        guard APIConfig.hasTMDBKey else {
            errorMessage = "Please configure your TMDB API key"
            return
        }

        isLoading = true
        errorMessage = nil
        currentPage = 1
        movies = []
        tvShows = []

        // Handle Favorites genre specially
        if selectedGenre?.id == SearchViewModel.favoritesGenre.id {
            await discoverFavorites()
            isLoading = false
            return
        }

        do {
            switch selectedContentType {
            case .movies:
                let response = try await tmdbService.discoverMovies(
                    page: currentPage,
                    genreId: selectedGenre?.id,
                    sortBy: selectedSortOption,
                    minYear: minYear,
                    maxYear: maxYear,
                    minRating: minRating,
                    region: APIConfig.selectedRegion
                )
                movies = response.results
                totalPages = response.totalPages

            case .tvShows:
                let response = try await tmdbService.discoverTVShows(
                    page: currentPage,
                    genreId: selectedGenre?.id,
                    sortBy: selectedSortOption,
                    minYear: minYear,
                    maxYear: maxYear,
                    minRating: minRating,
                    region: APIConfig.selectedRegion
                )
                tvShows = response.results
                totalPages = response.totalPages
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func discoverFavorites() async {
        guard let favoritesViewModel = favoritesViewModel else {
            // Fallback to popular if no favoritesViewModel
            await discoverPopular()
            return
        }

        do {
            switch selectedContentType {
            case .movies:
                let favoriteMovies = favoritesViewModel.movieFavorites
                if favoriteMovies.isEmpty {
                    // No favorites, show popular
                    await discoverPopular()
                    return
                }

                // Get recommendations for each favorite
                var recommendedMovies: [Movie] = []
                var seenIds = Set<Int>()

                // First, convert favorites to Movie objects and add them
                for favorite in favoriteMovies {
                    seenIds.insert(favorite.tmdbId)
                }

                // Fetch recommendations for each favorite
                for favorite in favoriteMovies {
                    do {
                        let response = try await tmdbService.getMovieRecommendations(movieId: favorite.tmdbId)
                        for movie in response.results {
                            if !seenIds.contains(movie.id) {
                                seenIds.insert(movie.id)
                                recommendedMovies.append(movie)
                            }
                        }
                    } catch {
                        // Continue with other favorites if one fails
                    }
                }

                // Create Movie objects from favorites to show at top
                var favoriteMovieObjects: [Movie] = []
                for favorite in favoriteMovies {
                    let movie = Movie(
                        id: favorite.tmdbId,
                        title: favorite.title,
                        originalTitle: favorite.title,
                        overview: "",
                        releaseDate: favorite.releaseYear.map { "\($0)-01-01" } ?? "",
                        posterPath: favorite.posterPath,
                        backdropPath: nil,
                        genreIds: [],
                        voteAverage: 0,
                        voteCount: 0,
                        popularity: 0
                    )
                    favoriteMovieObjects.append(movie)
                }

                // Combine: favorites first, then recommendations
                movies = favoriteMovieObjects + recommendedMovies
                totalPages = 1

            case .tvShows:
                let favoriteTVShows = favoritesViewModel.tvShowFavorites
                if favoriteTVShows.isEmpty {
                    // No favorites, show popular
                    await discoverPopular()
                    return
                }

                // Get recommendations for each favorite
                var recommendedShows: [TVShow] = []
                var seenIds = Set<Int>()

                // First, mark favorite IDs as seen
                for favorite in favoriteTVShows {
                    seenIds.insert(favorite.tmdbId)
                }

                // Fetch recommendations for each favorite
                for favorite in favoriteTVShows {
                    do {
                        let response = try await tmdbService.getTVShowRecommendations(tvId: favorite.tmdbId)
                        for show in response.results {
                            if !seenIds.contains(show.id) {
                                seenIds.insert(show.id)
                                recommendedShows.append(show)
                            }
                        }
                    } catch {
                        // Continue with other favorites if one fails
                    }
                }

                // Create TVShow objects from favorites to show at top
                var favoriteTVShowObjects: [TVShow] = []
                for favorite in favoriteTVShows {
                    let show = TVShow(
                        id: favorite.tmdbId,
                        name: favorite.title,
                        originalName: favorite.title,
                        overview: "",
                        firstAirDate: favorite.releaseYear.map { "\($0)-01-01" } ?? "",
                        posterPath: favorite.posterPath,
                        backdropPath: nil,
                        genreIds: [],
                        voteAverage: 0,
                        voteCount: 0,
                        popularity: 0
                    )
                    favoriteTVShowObjects.append(show)
                }

                // Combine: favorites first, then recommendations
                tvShows = favoriteTVShowObjects + recommendedShows
                totalPages = 1
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func discoverPopular() async {
        do {
            switch selectedContentType {
            case .movies:
                let response = try await tmdbService.discoverMovies(
                    page: 1,
                    sortBy: .popularityDesc,
                    region: APIConfig.selectedRegion
                )
                movies = response.results
                totalPages = 1

            case .tvShows:
                let response = try await tmdbService.discoverTVShows(
                    page: 1,
                    sortBy: .popularityDesc,
                    region: APIConfig.selectedRegion
                )
                tvShows = response.results
                totalPages = 1
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadMore() async {
        guard hasMorePages, !isLoading else { return }

        isLoading = true
        currentPage += 1

        do {
            switch selectedContentType {
            case .movies:
                let response = try await tmdbService.discoverMovies(
                    page: currentPage,
                    genreId: selectedGenre?.id,
                    sortBy: selectedSortOption,
                    minYear: minYear,
                    maxYear: maxYear,
                    minRating: minRating,
                    region: APIConfig.selectedRegion
                )
                movies.append(contentsOf: response.results)

            case .tvShows:
                let response = try await tmdbService.discoverTVShows(
                    page: currentPage,
                    genreId: selectedGenre?.id,
                    sortBy: selectedSortOption,
                    minYear: minYear,
                    maxYear: maxYear,
                    minRating: minRating,
                    region: APIConfig.selectedRegion
                )
                tvShows.append(contentsOf: response.results)
            }
        } catch {
            errorMessage = error.localizedDescription
            currentPage -= 1
        }

        isLoading = false
    }

    func fetchRatingsForMovie(at index: Int) async {
        guard APIConfig.hasOMDbKey else { return }
        guard index < movies.count else { return }
        guard movies[index].imdbRating == nil else { return }

        do {
            if movies[index].imdbId == nil {
                let imdbId = try await tmdbService.getMovieIMDbId(movieId: movies[index].id)
                movies[index].imdbId = imdbId
            }

            if let imdbId = movies[index].imdbId {
                let ratings = try await omdbService.fetchRatings(imdbId: imdbId)
                movies[index].imdbRating = ratings.imdbRatingDouble
                movies[index].rottenTomatoesRating = ratings.rottenTomatoesScore
            }
        } catch {
            // Silently fail for individual rating fetches
        }
    }

    func fetchRatingsForTVShow(at index: Int) async {
        guard APIConfig.hasOMDbKey else { return }
        guard index < tvShows.count else { return }
        guard tvShows[index].imdbRating == nil else { return }

        do {
            if tvShows[index].imdbId == nil {
                let imdbId = try await tmdbService.getTVShowIMDbId(tvId: tvShows[index].id)
                tvShows[index].imdbId = imdbId
            }

            if let imdbId = tvShows[index].imdbId {
                let ratings = try await omdbService.fetchRatings(imdbId: imdbId)
                tvShows[index].imdbRating = ratings.imdbRatingDouble
                tvShows[index].rottenTomatoesRating = ratings.rottenTomatoesScore
            }
        } catch {
            // Silently fail for individual rating fetches
        }
    }

    func resetFilters() {
        selectedGenre = nil
        selectedSortOption = .popularityDesc
        minYear = nil
        maxYear = nil
        minRating = nil
    }

    func sortLocally() {
        switch selectedSortOption {
        case .imdbRatingDesc:
            movies.sort { ($0.imdbRating ?? 0) > ($1.imdbRating ?? 0) }
            tvShows.sort { ($0.imdbRating ?? 0) > ($1.imdbRating ?? 0) }
        case .imdbRatingAsc:
            movies.sort {
                guard let r1 = $0.imdbRating else { return false }
                guard let r2 = $1.imdbRating else { return true }
                return r1 < r2
            }
            tvShows.sort {
                guard let r1 = $0.imdbRating else { return false }
                guard let r2 = $1.imdbRating else { return true }
                return r1 < r2
            }
        case .rtRatingDesc:
            movies.sort { ($0.rottenTomatoesRating ?? 0) > ($1.rottenTomatoesRating ?? 0) }
            tvShows.sort { ($0.rottenTomatoesRating ?? 0) > ($1.rottenTomatoesRating ?? 0) }
        case .rtRatingAsc:
            movies.sort {
                guard let r1 = $0.rottenTomatoesRating else { return false }
                guard let r2 = $1.rottenTomatoesRating else { return true }
                return r1 < r2
            }
            tvShows.sort {
                guard let r1 = $0.rottenTomatoesRating else { return false }
                guard let r2 = $1.rottenTomatoesRating else { return true }
                return r1 < r2
            }
        default:
            break
        }
    }

    func getWatchLink(for movie: Movie) async -> URL? {
        APIConfig.selectedPlatform.searchURL(for: movie.title)
    }

    func getWatchLink(for show: TVShow) async -> URL? {
        APIConfig.selectedPlatform.searchURL(for: show.name)
    }
}
