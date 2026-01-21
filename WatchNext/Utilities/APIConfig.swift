import Foundation

enum APIConfig {
    static var tmdbApiKey: String {
        if let key = ProcessInfo.processInfo.environment["TMDB_API_KEY"], !key.isEmpty {
            return key
        }
        if let key = UserDefaults.standard.string(forKey: "TMDB_API_KEY"), !key.isEmpty {
            return key
        }
        return ""
    }

    static var omdbApiKey: String {
        if let key = ProcessInfo.processInfo.environment["OMDB_API_KEY"], !key.isEmpty {
            return key
        }
        if let key = UserDefaults.standard.string(forKey: "OMDB_API_KEY"), !key.isEmpty {
            return key
        }
        return ""
    }

    static func setTMDBApiKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: "TMDB_API_KEY")
    }

    static func setOMDbApiKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: "OMDB_API_KEY")
    }

    static var hasTMDBKey: Bool {
        !tmdbApiKey.isEmpty
    }

    static var hasOMDbKey: Bool {
        !omdbApiKey.isEmpty
    }

    static var hasAllKeys: Bool {
        hasTMDBKey && hasOMDbKey
    }

    static var selectedRegion: String {
        get {
            UserDefaults.standard.string(forKey: "SELECTED_REGION") ?? Constants.TMDB.Region.defaultRegion
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "SELECTED_REGION")
        }
    }

    static func setRegion(_ code: String) {
        UserDefaults.standard.set(code, forKey: "SELECTED_REGION")
    }

    static var selectedPlatformId: String {
        get {
            UserDefaults.standard.string(forKey: "SELECTED_PLATFORM") ?? "appletv"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "SELECTED_PLATFORM")
        }
    }

    static var selectedPlatform: Constants.TMDB.StreamingPlatform {
        Constants.TMDB.StreamingPlatform.find(by: selectedPlatformId) ?? Constants.TMDB.StreamingPlatform.allPlatforms[0]
    }

    static func setPlatform(_ id: String) {
        UserDefaults.standard.set(id, forKey: "SELECTED_PLATFORM")
    }
}
