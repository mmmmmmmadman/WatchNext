import Foundation
import SwiftUI

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

            func searchURL(for title: String) -> URL? {
                guard let encoded = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                    return nil
                }

                let urlString: String
                switch id {
                case "appletv":
                    urlString = "https://www.google.com/search?q=\(encoded)+site:tv.apple.com"
                case "netflix":
                    urlString = "https://www.google.com/search?q=\(encoded)+site:netflix.com"
                case "prime":
                    urlString = "https://www.google.com/search?q=\(encoded)+site:primevideo.com"
                case "disney":
                    urlString = "https://www.google.com/search?q=\(encoded)+site:disneyplus.com"
                default:
                    return nil
                }

                return URL(string: urlString)
            }
        }

        enum Region {
            static let defaultRegion = "TW"

            static let availableRegions: [(code: String, name: String)] = [
                // East Asia
                ("TW", "Taiwan"),
                ("JP", "Japan"),
                ("HK", "Hong Kong"),
                ("KR", "South Korea"),

                // Southeast Asia
                ("SG", "Singapore"),
                ("MY", "Malaysia"),
                ("TH", "Thailand"),
                ("PH", "Philippines"),
                ("ID", "Indonesia"),

                // South Asia
                ("IN", "India"),
                ("PK", "Pakistan"),

                // Middle East
                ("AE", "United Arab Emirates"),
                ("SA", "Saudi Arabia"),
                ("IL", "Israel"),
                ("TR", "Turkey"),
                ("QA", "Qatar"),
                ("KW", "Kuwait"),
                ("BH", "Bahrain"),
                ("OM", "Oman"),
                ("JO", "Jordan"),
                ("LB", "Lebanon"),
                ("IQ", "Iraq"),
                ("PS", "Palestine"),
                ("YE", "Yemen"),

                // North Africa
                ("EG", "Egypt"),
                ("MA", "Morocco"),
                ("DZ", "Algeria"),
                ("TN", "Tunisia"),
                ("LY", "Libya"),

                // Sub-Saharan Africa
                ("ZA", "South Africa"),
                ("NG", "Nigeria"),
                ("KE", "Kenya"),
                ("GH", "Ghana"),
                ("TZ", "Tanzania"),
                ("UG", "Uganda"),
                ("ZM", "Zambia"),
                ("MU", "Mauritius"),
                ("MZ", "Mozambique"),
                ("SN", "Senegal"),
                ("CI", "Ivory Coast"),
                ("NE", "Niger"),
                ("CV", "Cape Verde"),
                ("GQ", "Equatorial Guinea"),

                // North America
                ("US", "United States"),
                ("CA", "Canada"),
                ("MX", "Mexico"),

                // Central America & Caribbean
                ("CR", "Costa Rica"),
                ("GT", "Guatemala"),
                ("PA", "Panama"),
                ("HN", "Honduras"),
                ("SV", "El Salvador"),
                ("CU", "Cuba"),
                ("DO", "Dominican Republic"),
                ("JM", "Jamaica"),
                ("TT", "Trinidad and Tobago"),
                ("BS", "Bahamas"),
                ("BB", "Barbados"),
                ("AG", "Antigua and Barbuda"),
                ("LC", "Saint Lucia"),
                ("TC", "Turks and Caicos Islands"),
                ("BM", "Bermuda"),

                // South America
                ("BR", "Brazil"),
                ("AR", "Argentina"),
                ("CL", "Chile"),
                ("CO", "Colombia"),
                ("PE", "Peru"),
                ("VE", "Venezuela"),
                ("EC", "Ecuador"),
                ("BO", "Bolivia"),
                ("PY", "Paraguay"),
                ("UY", "Uruguay"),
                ("GF", "French Guiana"),

                // Western Europe
                ("GB", "United Kingdom"),
                ("IE", "Ireland"),
                ("FR", "France"),
                ("DE", "Germany"),
                ("NL", "Netherlands"),
                ("BE", "Belgium"),
                ("AT", "Austria"),
                ("CH", "Switzerland"),
                ("LI", "Liechtenstein"),
                ("MC", "Monaco"),
                ("LU", "Luxembourg"),

                // Southern Europe
                ("IT", "Italy"),
                ("ES", "Spain"),
                ("PT", "Portugal"),
                ("GR", "Greece"),
                ("MT", "Malta"),
                ("SM", "San Marino"),
                ("VA", "Vatican City"),
                ("AD", "Andorra"),
                ("GI", "Gibraltar"),

                // Northern Europe
                ("SE", "Sweden"),
                ("NO", "Norway"),
                ("DK", "Denmark"),
                ("FI", "Finland"),
                ("IS", "Iceland"),
                ("EE", "Estonia"),
                ("LV", "Latvia"),
                ("LT", "Lithuania"),
                ("GG", "Guernsey"),

                // Central & Eastern Europe
                ("PL", "Poland"),
                ("CZ", "Czech Republic"),
                ("SK", "Slovakia"),
                ("HU", "Hungary"),
                ("RO", "Romania"),
                ("BG", "Bulgaria"),
                ("HR", "Croatia"),
                ("SI", "Slovenia"),
                ("RS", "Serbia"),
                ("BA", "Bosnia and Herzegovina"),
                ("AL", "Albania"),
                ("MK", "North Macedonia"),
                ("XK", "Kosovo"),
                ("MD", "Moldova"),
                ("RU", "Russia"),

                // Oceania
                ("AU", "Australia"),
                ("NZ", "New Zealand"),
                ("FJ", "Fiji"),
                ("PF", "French Polynesia"),
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

// MARK: - Color Extensions
extension Color {
    // Brand Colors
    static let brandPrimary = Color("BrandPrimary", bundle: nil)
    static let brandSecondary = Color("BrandSecondary", bundle: nil)

    // MADZINE Brand Color (Orange-Yellow)
    static let madzineOrange = Color(red: 1.0, green: 0.6, blue: 0.0)

    // Rating Badge Colors
    static let tmdbBlue = Color("TMDBBlue", bundle: nil)
    static let imdbGold = Color("IMDbGold", bundle: nil)
    static let rtRed = Color("RTRed", bundle: nil)

    // Fallback colors
    static var tmdbBlueFallback: Color {
        Color(red: 0.01, green: 0.66, blue: 0.86)
    }

    static var imdbGoldFallback: Color {
        Color(red: 0.95, green: 0.71, blue: 0.20)
    }

    static var rtRedFallback: Color {
        Color(red: 0.98, green: 0.22, blue: 0.26)
    }

    // Brand color variants for different UI contexts
    static var brandAccent: Color {
        Color.accentColor
    }

    static var brandSubtle: Color {
        brandSecondary.opacity(0.5)
    }
}

// MARK: - Typography Extensions
extension Font {
    static func cardTitle(for platform: PlatformType) -> Font {
        switch platform {
        case .iOS:
            return .system(size: 14, weight: .semibold)
        case .macOS:
            return .system(size: 13, weight: .medium)
        }
    }

    static func cardYear(for platform: PlatformType) -> Font {
        switch platform {
        case .iOS:
            return .system(size: 12)
        case .macOS:
            return .caption
        }
    }

    static func ratingLabel(for platform: PlatformType) -> Font {
        switch platform {
        case .iOS:
            return .system(size: 9, weight: .medium)
        case .macOS:
            return .system(size: 8)
        }
    }

    static func ratingValue(for platform: PlatformType) -> Font {
        switch platform {
        case .iOS:
            return .system(size: 11, weight: .bold)
        case .macOS:
            return .system(size: 10, weight: .bold)
        }
    }
}

enum PlatformType {
    case iOS
    case macOS

    static var current: PlatformType {
        #if os(iOS)
        return .iOS
        #else
        return .macOS
        #endif
    }
}
