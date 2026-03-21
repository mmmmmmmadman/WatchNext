import Foundation

actor TMDBService {
    private let baseURL = Constants.TMDB.baseURL

    private var apiKey: String {
        APIConfig.tmdbApiKey
    }

    struct DiscoverResponse<T: Codable>: Codable {
        let page: Int
        let results: [T]
        let totalPages: Int
        let totalResults: Int

        enum CodingKeys: String, CodingKey {
            case page, results
            case totalPages = "total_pages"
            case totalResults = "total_results"
        }
    }

    struct MovieDetailsResponse: Codable {
        let id: Int
        let imdbId: String?

        enum CodingKeys: String, CodingKey {
            case id
            case imdbId = "imdb_id"
        }
    }

    struct TVExternalIdsResponse: Codable {
        let id: Int
        let imdbId: String?

        enum CodingKeys: String, CodingKey {
            case id
            case imdbId = "imdb_id"
        }
    }

    struct WatchProvidersResponse: Codable {
        let id: Int
        let results: [String: WatchProviderRegion]
    }

    struct WatchProviderRegion: Codable {
        let link: String?
        let flatrate: [WatchProviderInfo]?
        let buy: [WatchProviderInfo]?
        let rent: [WatchProviderInfo]?
    }

    struct WatchProviderInfo: Codable {
        let providerId: Int
        let providerName: String

        enum CodingKeys: String, CodingKey {
            case providerId = "provider_id"
            case providerName = "provider_name"
        }
    }

    func discoverMovies(
        page: Int = 1,
        genreId: Int? = nil,
        sortBy: SortOption = .tmdbRatingDesc,
        minYear: Int? = nil,
        maxYear: Int? = nil,
        minRating: Double? = nil,
        region: String = APIConfig.selectedRegion,
        platform: Constants.TMDB.StreamingPlatform = APIConfig.selectedPlatform
    ) async throws -> DiscoverResponse<Movie> {
        let providerString = platform.providerIds.map { String($0) }.joined(separator: "|")
        var components = URLComponents(string: "\(baseURL)/discover/movie")!
        var queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "watch_region", value: region),
            URLQueryItem(name: "with_watch_providers", value: providerString),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "sort_by", value: sortBy.apiSortValue),
            URLQueryItem(name: "include_adult", value: "false"),
        ]

        if let genreId = genreId {
            queryItems.append(URLQueryItem(name: "with_genres", value: String(genreId)))
        }

        if let minYear = minYear {
            queryItems.append(URLQueryItem(name: "primary_release_date.gte", value: "\(minYear)-01-01"))
        }

        if let maxYear = maxYear {
            queryItems.append(URLQueryItem(name: "primary_release_date.lte", value: "\(maxYear)-12-31"))
        }

        if let minRating = minRating {
            queryItems.append(URLQueryItem(name: "vote_average.gte", value: String(minRating)))
            queryItems.append(URLQueryItem(name: "vote_count.gte", value: "50"))
        }

        components.queryItems = queryItems

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }

        return try JSONDecoder().decode(DiscoverResponse<Movie>.self, from: data)
    }

    func discoverTVShows(
        page: Int = 1,
        genreId: Int? = nil,
        sortBy: SortOption = .tmdbRatingDesc,
        minYear: Int? = nil,
        maxYear: Int? = nil,
        minRating: Double? = nil,
        region: String = APIConfig.selectedRegion,
        platform: Constants.TMDB.StreamingPlatform = APIConfig.selectedPlatform
    ) async throws -> DiscoverResponse<TVShow> {
        let providerString = platform.providerIds.map { String($0) }.joined(separator: "|")
        var components = URLComponents(string: "\(baseURL)/discover/tv")!
        var queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "watch_region", value: region),
            URLQueryItem(name: "with_watch_providers", value: providerString),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "sort_by", value: sortBy.apiSortValue.replacingOccurrences(of: "release_date", with: "first_air_date")),
            URLQueryItem(name: "include_adult", value: "false"),
        ]

        if let genreId = genreId {
            queryItems.append(URLQueryItem(name: "with_genres", value: String(genreId)))
        }

        if let minYear = minYear {
            queryItems.append(URLQueryItem(name: "first_air_date.gte", value: "\(minYear)-01-01"))
        }

        if let maxYear = maxYear {
            queryItems.append(URLQueryItem(name: "first_air_date.lte", value: "\(maxYear)-12-31"))
        }

        if let minRating = minRating {
            queryItems.append(URLQueryItem(name: "vote_average.gte", value: String(minRating)))
            queryItems.append(URLQueryItem(name: "vote_count.gte", value: "50"))
        }

        components.queryItems = queryItems

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }

        return try JSONDecoder().decode(DiscoverResponse<TVShow>.self, from: data)
    }

    func getMovieGenres() async throws -> [Genre] {
        var components = URLComponents(string: "\(baseURL)/genre/movie/list")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: "en-US"),
        ]

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }

        let genresResponse = try JSONDecoder().decode(GenresResponse.self, from: data)
        return genresResponse.genres
    }

    func getTVGenres() async throws -> [Genre] {
        var components = URLComponents(string: "\(baseURL)/genre/tv/list")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "language", value: "en-US"),
        ]

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }

        let genresResponse = try JSONDecoder().decode(GenresResponse.self, from: data)
        return genresResponse.genres
    }

    func getMovieIMDbId(movieId: Int) async throws -> String? {
        var components = URLComponents(string: "\(baseURL)/movie/\(movieId)")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
        ]

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }

        let details = try JSONDecoder().decode(MovieDetailsResponse.self, from: data)
        return details.imdbId
    }

    func getTVShowIMDbId(tvId: Int) async throws -> String? {
        var components = URLComponents(string: "\(baseURL)/tv/\(tvId)/external_ids")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
        ]

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }

        let externalIds = try JSONDecoder().decode(TVExternalIdsResponse.self, from: data)
        return externalIds.imdbId
    }

    func getMovieWatchProviderLink(movieId: Int, region: String = APIConfig.selectedRegion) async throws -> String? {
        var components = URLComponents(string: "\(baseURL)/movie/\(movieId)/watch/providers")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
        ]

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }

        let watchProviders = try JSONDecoder().decode(WatchProvidersResponse.self, from: data)
        return watchProviders.results[region]?.link
    }

    func getTVShowWatchProviderLink(tvId: Int, region: String = APIConfig.selectedRegion) async throws -> String? {
        var components = URLComponents(string: "\(baseURL)/tv/\(tvId)/watch/providers")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
        ]

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }

        let watchProviders = try JSONDecoder().decode(WatchProvidersResponse.self, from: data)
        return watchProviders.results[region]?.link
    }

    func isMovieAvailableOnPlatform(movieId: Int, platform: Constants.TMDB.StreamingPlatform, region: String = APIConfig.selectedRegion) async throws -> Bool {
        var components = URLComponents(string: "\(baseURL)/movie/\(movieId)/watch/providers")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
        ]

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }

        let watchProviders = try JSONDecoder().decode(WatchProvidersResponse.self, from: data)

        // 如果該地區沒有數據，保留項目（返回 true）
        guard let regionData = watchProviders.results[region] else { return true }

        let allProviders = (regionData.flatrate ?? []) + (regionData.buy ?? []) + (regionData.rent ?? [])

        // 如果該地區沒有任何平台數據，保留項目
        if allProviders.isEmpty { return true }

        let availableIds = Set(allProviders.map { $0.providerId })
        return !platform.providerIds.filter { availableIds.contains($0) }.isEmpty
    }

    func isTVShowAvailableOnPlatform(tvId: Int, platform: Constants.TMDB.StreamingPlatform, region: String = APIConfig.selectedRegion) async throws -> Bool {
        var components = URLComponents(string: "\(baseURL)/tv/\(tvId)/watch/providers")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
        ]

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }

        let watchProviders = try JSONDecoder().decode(WatchProvidersResponse.self, from: data)

        // 如果該地區沒有數據，保留項目（返回 true）
        guard let regionData = watchProviders.results[region] else { return true }

        let allProviders = (regionData.flatrate ?? []) + (regionData.buy ?? []) + (regionData.rent ?? [])

        // 如果該地區沒有任何平台數據，保留項目
        if allProviders.isEmpty { return true }

        let availableIds = Set(allProviders.map { $0.providerId })
        return !platform.providerIds.filter { availableIds.contains($0) }.isEmpty
    }

    // MARK: - Provider Regions

    struct WatchProviderListResponse: Codable {
        let results: [WatchProviderDetail]
    }

    struct WatchProviderDetail: Codable {
        let providerId: Int
        let providerName: String
        let displayPriorities: [String: Int]

        enum CodingKeys: String, CodingKey {
            case providerId = "provider_id"
            case providerName = "provider_name"
            case displayPriorities = "display_priorities"
        }
    }

    /// 查詢所有 provider 支援的地區，回傳 [providerId: Set<regionCode>]
    func fetchProviderRegions() async throws -> [Int: Set<String>] {
        var components = URLComponents(string: "\(baseURL)/watch/providers/movie")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
        ]

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }

        let listResponse = try JSONDecoder().decode(WatchProviderListResponse.self, from: data)

        var result: [Int: Set<String>] = [:]
        for provider in listResponse.results {
            result[provider.providerId] = Set(provider.displayPriorities.keys)
        }
        return result
    }

    // MARK: - Recommendations

    func getMovieRecommendations(movieId: Int, page: Int = 1) async throws -> DiscoverResponse<Movie> {
        var components = URLComponents(string: "\(baseURL)/movie/\(movieId)/recommendations")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "page", value: String(page)),
        ]

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }

        return try JSONDecoder().decode(DiscoverResponse<Movie>.self, from: data)
    }

    func getTVShowRecommendations(tvId: Int, page: Int = 1) async throws -> DiscoverResponse<TVShow> {
        var components = URLComponents(string: "\(baseURL)/tv/\(tvId)/recommendations")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "page", value: String(page)),
        ]

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }

        return try JSONDecoder().decode(DiscoverResponse<TVShow>.self, from: data)
    }

    func searchMovies(query: String, page: Int = 1) async throws -> DiscoverResponse<Movie> {
        var components = URLComponents(string: "\(baseURL)/search/movie")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "include_adult", value: "false"),
        ]

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }

        return try JSONDecoder().decode(DiscoverResponse<Movie>.self, from: data)
    }

    func searchTVShows(query: String, page: Int = 1) async throws -> DiscoverResponse<TVShow> {
        var components = URLComponents(string: "\(baseURL)/search/tv")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "include_adult", value: "false"),
        ]

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }

        return try JSONDecoder().decode(DiscoverResponse<TVShow>.self, from: data)
    }

    // MARK: - Company Search

    func searchCompanies(query: String) async throws -> [Company] {
        var components = URLComponents(string: "\(baseURL)/search/company")!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "query", value: query),
        ]

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }

        let result = try JSONDecoder().decode(CompanySearchResponse.self, from: data)
        return result.results
    }

    func discoverMoviesByCompany(
        companyId: Int,
        page: Int = 1,
        genreId: Int? = nil,
        sortBy: SortOption = .tmdbRatingDesc,
        minYear: Int? = nil,
        maxYear: Int? = nil,
        minRating: Double? = nil,
        region: String? = nil,
        platform: Constants.TMDB.StreamingPlatform? = nil
    ) async throws -> DiscoverResponse<Movie> {
        var components = URLComponents(string: "\(baseURL)/discover/movie")!
        var queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "with_companies", value: String(companyId)),
            URLQueryItem(name: "sort_by", value: sortBy.apiSortValue),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "include_adult", value: "false"),
        ]

        if let region = region, let platform = platform {
            let providerString = platform.providerIds.map { String($0) }.joined(separator: "|")
            queryItems.append(URLQueryItem(name: "watch_region", value: region))
            queryItems.append(URLQueryItem(name: "with_watch_providers", value: providerString))
        }
        if let genreId = genreId {
            queryItems.append(URLQueryItem(name: "with_genres", value: String(genreId)))
        }
        if let minYear = minYear {
            queryItems.append(URLQueryItem(name: "primary_release_date.gte", value: "\(minYear)-01-01"))
        }
        if let maxYear = maxYear {
            queryItems.append(URLQueryItem(name: "primary_release_date.lte", value: "\(maxYear)-12-31"))
        }
        if let minRating = minRating {
            queryItems.append(URLQueryItem(name: "vote_average.gte", value: String(minRating)))
            queryItems.append(URLQueryItem(name: "vote_count.gte", value: "50"))
        }

        components.queryItems = queryItems

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }

        return try JSONDecoder().decode(DiscoverResponse<Movie>.self, from: data)
    }

    func discoverTVShowsByCompany(
        companyId: Int,
        page: Int = 1,
        genreId: Int? = nil,
        sortBy: SortOption = .tmdbRatingDesc,
        minYear: Int? = nil,
        maxYear: Int? = nil,
        minRating: Double? = nil,
        region: String? = nil,
        platform: Constants.TMDB.StreamingPlatform? = nil
    ) async throws -> DiscoverResponse<TVShow> {
        var components = URLComponents(string: "\(baseURL)/discover/tv")!
        var queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "with_companies", value: String(companyId)),
            URLQueryItem(name: "sort_by", value: sortBy.apiSortValue.replacingOccurrences(of: "release_date", with: "first_air_date")),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "include_adult", value: "false"),
        ]

        if let region = region, let platform = platform {
            let providerString = platform.providerIds.map { String($0) }.joined(separator: "|")
            queryItems.append(URLQueryItem(name: "watch_region", value: region))
            queryItems.append(URLQueryItem(name: "with_watch_providers", value: providerString))
        }
        if let genreId = genreId {
            queryItems.append(URLQueryItem(name: "with_genres", value: String(genreId)))
        }
        if let minYear = minYear {
            queryItems.append(URLQueryItem(name: "first_air_date.gte", value: "\(minYear)-01-01"))
        }
        if let maxYear = maxYear {
            queryItems.append(URLQueryItem(name: "first_air_date.lte", value: "\(maxYear)-12-31"))
        }
        if let minRating = minRating {
            queryItems.append(URLQueryItem(name: "vote_average.gte", value: String(minRating)))
            queryItems.append(URLQueryItem(name: "vote_count.gte", value: "50"))
        }

        components.queryItems = queryItems

        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }

        return try JSONDecoder().decode(DiscoverResponse<TVShow>.self, from: data)
    }
}

enum TMDBError: Error, LocalizedError {
    case invalidResponse
    case apiKeyMissing
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from TMDB API"
        case .apiKeyMissing:
            return "TMDB API key is not configured"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
