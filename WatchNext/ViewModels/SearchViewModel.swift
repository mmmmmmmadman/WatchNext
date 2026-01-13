import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
class SearchViewModel {
    var movies: [Movie] = []
    var tvShows: [TVShow] = []
    var isLoading = false
    var errorMessage: String?
    var currentPage = 1
    var totalPages = 1
    var hasMorePages: Bool { currentPage < totalPages }

    var searchQuery: String = ""
    var isSearchMode: Bool { !searchQuery.isEmpty }

    var selectedContentType: ContentType = .movies
    var selectedGenre: Genre?
    var selectedSortOption: SortOption = .popularityDesc
    var minYear: Int?
    var maxYear: Int?
    var minRating: Double?

    var movieGenres: [Genre] = []
    var tvGenres: [Genre] = []

    var currentGenres: [Genre] {
        selectedContentType == .movies ? movieGenres : tvGenres
    }

    private let tmdbService = TMDBService()
    private let omdbService = OMDbService()
    private var cacheService: CacheService?

    func setCacheService(_ service: CacheService) {
        self.cacheService = service
    }

    func loadGenres() async {
        do {
            async let movieGenresTask = tmdbService.getMovieGenres()
            async let tvGenresTask = tmdbService.getTVGenres()

            movieGenres = try await movieGenresTask
            tvGenres = try await tvGenresTask
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func search() async {
        guard APIConfig.hasTMDBKey else {
            errorMessage = "Please configure your TMDB API key"
            return
        }

        isLoading = true
        errorMessage = nil
        currentPage = 1
        movies = []
        tvShows = []

        do {
            if isSearchMode {
                // Keyword search mode
                switch selectedContentType {
                case .movies:
                    let response = try await tmdbService.searchMovies(query: searchQuery, page: currentPage)
                    movies = response.results
                    totalPages = response.totalPages

                case .tvShows:
                    let response = try await tmdbService.searchTVShows(query: searchQuery, page: currentPage)
                    tvShows = response.results
                    totalPages = response.totalPages
                }
            } else {
                // Discovery mode (platform filtered)
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
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadMore() async {
        guard hasMorePages, !isLoading else { return }

        isLoading = true
        currentPage += 1

        do {
            if isSearchMode {
                switch selectedContentType {
                case .movies:
                    let response = try await tmdbService.searchMovies(query: searchQuery, page: currentPage)
                    movies.append(contentsOf: response.results)

                case .tvShows:
                    let response = try await tmdbService.searchTVShows(query: searchQuery, page: currentPage)
                    tvShows.append(contentsOf: response.results)
                }
            } else {
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
            movies.sort { ($0.imdbRating ?? 0) < ($1.imdbRating ?? 0) }
            tvShows.sort { ($0.imdbRating ?? 0) < ($1.imdbRating ?? 0) }
        case .rtRatingDesc:
            movies.sort { ($0.rottenTomatoesRating ?? 0) > ($1.rottenTomatoesRating ?? 0) }
            tvShows.sort { ($0.rottenTomatoesRating ?? 0) > ($1.rottenTomatoesRating ?? 0) }
        case .rtRatingAsc:
            movies.sort { ($0.rottenTomatoesRating ?? 0) < ($1.rottenTomatoesRating ?? 0) }
            tvShows.sort { ($0.rottenTomatoesRating ?? 0) < ($1.rottenTomatoesRating ?? 0) }
        default:
            break
        }
    }

    func getWatchLink(for movie: Movie) async -> URL? {
        do {
            if let link = try await tmdbService.getMovieWatchProviderLink(movieId: movie.id) {
                return URL(string: link)
            }
        } catch {
            // Silently fail
        }
        return nil
    }

    func getWatchLink(for show: TVShow) async -> URL? {
        do {
            if let link = try await tmdbService.getTVShowWatchProviderLink(tvId: show.id) {
                return URL(string: link)
            }
        } catch {
            // Silently fail
        }
        return nil
    }
}
