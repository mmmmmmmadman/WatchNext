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
                ("AL", "Albania"),
                ("DZ", "Algeria"),
                ("AD", "Andorra"),
                ("AG", "Antigua and Barbuda"),
                ("AR", "Argentina"),
                ("AU", "Australia"),
                ("AT", "Austria"),
                ("BS", "Bahamas"),
                ("BH", "Bahrain"),
                ("BB", "Barbados"),
                ("BE", "Belgium"),
                ("BM", "Bermuda"),
                ("BO", "Bolivia"),
                ("BA", "Bosnia and Herzegovina"),
                ("BR", "Brazil"),
                ("BG", "Bulgaria"),
                ("CA", "Canada"),
                ("CV", "Cape Verde"),
                ("CL", "Chile"),
                ("CO", "Colombia"),
                ("CR", "Costa Rica"),
                ("HR", "Croatia"),
                ("CU", "Cuba"),
                ("CZ", "Czech Republic"),
                ("DK", "Denmark"),
                ("DO", "Dominican Republic"),
                ("EC", "Ecuador"),
                ("EG", "Egypt"),
                ("SV", "El Salvador"),
                ("GQ", "Equatorial Guinea"),
                ("EE", "Estonia"),
                ("FJ", "Fiji"),
                ("FI", "Finland"),
                ("FR", "France"),
                ("GF", "French Guiana"),
                ("PF", "French Polynesia"),
                ("DE", "Germany"),
                ("GH", "Ghana"),
                ("GI", "Gibraltar"),
                ("GR", "Greece"),
                ("GT", "Guatemala"),
                ("GG", "Guernsey"),
                ("HN", "Honduras"),
                ("HK", "Hong Kong"),
                ("HU", "Hungary"),
                ("IS", "Iceland"),
                ("IN", "India"),
                ("ID", "Indonesia"),
                ("IQ", "Iraq"),
                ("IE", "Ireland"),
                ("IL", "Israel"),
                ("IT", "Italy"),
                ("CI", "Ivory Coast"),
                ("JM", "Jamaica"),
                ("JP", "Japan"),
                ("JO", "Jordan"),
                ("KE", "Kenya"),
                ("XK", "Kosovo"),
                ("KW", "Kuwait"),
                ("LV", "Latvia"),
                ("LB", "Lebanon"),
                ("LY", "Libya"),
                ("LI", "Liechtenstein"),
                ("LT", "Lithuania"),
                ("LU", "Luxembourg"),
                ("MY", "Malaysia"),
                ("MT", "Malta"),
                ("MU", "Mauritius"),
                ("MX", "Mexico"),
                ("MD", "Moldova"),
                ("MC", "Monaco"),
                ("MA", "Morocco"),
                ("MZ", "Mozambique"),
                ("NL", "Netherlands"),
                ("NZ", "New Zealand"),
                ("NE", "Niger"),
                ("NG", "Nigeria"),
                ("MK", "North Macedonia"),
                ("NO", "Norway"),
                ("OM", "Oman"),
                ("PK", "Pakistan"),
                ("PS", "Palestine"),
                ("PA", "Panama"),
                ("PY", "Paraguay"),
                ("PE", "Peru"),
                ("PH", "Philippines"),
                ("PL", "Poland"),
                ("PT", "Portugal"),
                ("QA", "Qatar"),
                ("RO", "Romania"),
                ("RU", "Russia"),
                ("LC", "Saint Lucia"),
                ("SM", "San Marino"),
                ("SA", "Saudi Arabia"),
                ("SN", "Senegal"),
                ("RS", "Serbia"),
                ("SG", "Singapore"),
                ("SK", "Slovakia"),
                ("SI", "Slovenia"),
                ("ZA", "South Africa"),
                ("KR", "South Korea"),
                ("ES", "Spain"),
                ("SE", "Sweden"),
                ("CH", "Switzerland"),
                ("TW", "Taiwan"),
                ("TZ", "Tanzania"),
                ("TH", "Thailand"),
                ("TT", "Trinidad and Tobago"),
                ("TN", "Tunisia"),
                ("TR", "Turkey"),
                ("TC", "Turks and Caicos Islands"),
                ("UG", "Uganda"),
                ("AE", "United Arab Emirates"),
                ("GB", "United Kingdom"),
                ("US", "United States"),
                ("UY", "Uruguay"),
                ("VA", "Vatican City"),
                ("VE", "Venezuela"),
                ("YE", "Yemen"),
                ("ZM", "Zambia"),
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

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .titleAsc: return "Title (A-Z)"
        case .titleDesc: return "Title (Z-A)"
        case .releaseDateAsc: return "Oldest First"
        case .releaseDateDesc: return "Newest First"
        case .tmdbRatingDesc: return "TMDB (High-Low)"
        case .tmdbRatingAsc: return "TMDB (Low-High)"
        }
    }

    var isLocalSort: Bool {
        return false
    }

    var apiSortValue: String {
        return rawValue
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
