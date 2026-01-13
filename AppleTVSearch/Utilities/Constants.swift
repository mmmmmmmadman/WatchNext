import Foundation

enum Constants {
    enum TMDB {
        static let baseURL = "https://api.themoviedb.org/3"
        static let imageBaseURL = "https://image.tmdb.org/t/p"

        enum WatchProvider {
            static let appleTVPlus = 350
            static let appleTV = 2
            static let netflix = 8
            static let amazonPrime = 9
            static let disneyPlus = 337
        }

        struct StreamingPlatform: Identifiable, Hashable {
            let id: String
            let name: String
            let providerIds: [Int]

            static let allPlatforms: [StreamingPlatform] = [
                StreamingPlatform(id: "appletv", name: "Apple TV", providerIds: [350, 2]),
                StreamingPlatform(id: "netflix", name: "Netflix", providerIds: [8]),
                StreamingPlatform(id: "prime", name: "Prime Video", providerIds: [9, 119]),
                StreamingPlatform(id: "disney", name: "Disney+", providerIds: [337]),
            ]

            static func find(by id: String) -> StreamingPlatform? {
                allPlatforms.first { $0.id == id }
            }
        }

        enum Region {
            static let defaultRegion = "TW"

            static let availableRegions: [(code: String, name: String)] = [
                ("TW", "Taiwan"),
                ("US", "United States"),
                ("JP", "Japan"),
                ("HK", "Hong Kong"),
                ("GB", "United Kingdom"),
                ("AU", "Australia"),
                ("CA", "Canada"),
                ("DE", "Germany"),
                ("FR", "France"),
                ("KR", "South Korea"),
                ("SG", "Singapore"),
            ]
        }
    }

    enum Cache {
        static let expirationInterval: TimeInterval = 86400
    }

    enum MovieGenres {
        static let action = 28
        static let adventure = 12
        static let animation = 16
        static let comedy = 35
        static let crime = 80
        static let documentary = 99
        static let drama = 18
        static let family = 10751
        static let fantasy = 14
        static let history = 36
        static let horror = 27
        static let music = 10402
        static let mystery = 9648
        static let romance = 10749
        static let scienceFiction = 878
        static let thriller = 53
        static let war = 10752
        static let western = 37
    }

    enum TVGenres {
        static let actionAdventure = 10759
        static let animation = 16
        static let comedy = 35
        static let crime = 80
        static let documentary = 99
        static let drama = 18
        static let family = 10751
        static let kids = 10762
        static let mystery = 9648
        static let news = 10763
        static let reality = 10764
        static let sciFiFantasy = 10765
        static let soap = 10766
        static let talk = 10767
        static let warPolitics = 10768
        static let western = 37
    }
}

enum SortOption: String, CaseIterable, Identifiable {
    case titleAsc = "title.asc"
    case titleDesc = "title.desc"
    case releaseDateAsc = "release_date.asc"
    case releaseDateDesc = "release_date.desc"
    case tmdbRatingDesc = "vote_average.desc"
    case tmdbRatingAsc = "vote_average.asc"
    case imdbRatingDesc = "imdb.desc"
    case imdbRatingAsc = "imdb.asc"
    case rtRatingDesc = "rt.desc"
    case rtRatingAsc = "rt.asc"
    case popularityAsc = "popularity.asc"
    case popularityDesc = "popularity.desc"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .titleAsc: return "Title (A-Z)"
        case .titleDesc: return "Title (Z-A)"
        case .releaseDateAsc: return "Oldest First"
        case .releaseDateDesc: return "Newest First"
        case .tmdbRatingDesc: return "TMDB (High-Low)"
        case .tmdbRatingAsc: return "TMDB (Low-High)"
        case .imdbRatingDesc: return "IMDb (High-Low)"
        case .imdbRatingAsc: return "IMDb (Low-High)"
        case .rtRatingDesc: return "RT (High-Low)"
        case .rtRatingAsc: return "RT (Low-High)"
        case .popularityAsc: return "Least Popular"
        case .popularityDesc: return "Most Popular"
        }
    }

    var isLocalSort: Bool {
        switch self {
        case .imdbRatingDesc, .imdbRatingAsc, .rtRatingDesc, .rtRatingAsc:
            return true
        default:
            return false
        }
    }

    var apiSortValue: String {
        switch self {
        case .imdbRatingDesc, .imdbRatingAsc, .rtRatingDesc, .rtRatingAsc:
            return "popularity.desc"
        default:
            return rawValue
        }
    }
}

enum ContentType: String, CaseIterable, Identifiable {
    case movies = "Movies"
    case tvShows = "TV Shows"

    var id: String { rawValue }
}
