import Foundation
import SwiftData

struct TVShow: Identifiable, Codable {
    let id: Int
    let name: String
    let originalName: String
    let overview: String
    let firstAirDate: String
    let posterPath: String?
    let backdropPath: String?
    let genreIds: [Int]
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double

    var imdbId: String?
    var imdbRating: Double?
    var rottenTomatoesRating: Int?

    var firstAirYear: Int? {
        guard firstAirDate.count >= 4 else { return nil }
        return Int(String(firstAirDate.prefix(4)))
    }

    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    var backdropURL: URL? {
        guard let path = backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w1280\(path)")
    }

    enum CodingKeys: String, CodingKey {
        case id, name, overview, popularity
        case originalName = "original_name"
        case firstAirDate = "first_air_date"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case genreIds = "genre_ids"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

@Model
final class CachedTVShow {
    @Attribute(.unique) var id: Int
    var name: String
    var originalName: String
    var overview: String
    var firstAirDate: String
    var posterPath: String?
    var genreIds: [Int]
    var voteAverage: Double
    var voteCount: Int
    var imdbId: String?
    var imdbRating: Double?
    var rottenTomatoesRating: Int?
    var cachedAt: Date

    init(from show: TVShow) {
        self.id = show.id
        self.name = show.name
        self.originalName = show.originalName
        self.overview = show.overview
        self.firstAirDate = show.firstAirDate
        self.posterPath = show.posterPath
        self.genreIds = show.genreIds
        self.voteAverage = show.voteAverage
        self.voteCount = show.voteCount
        self.imdbId = show.imdbId
        self.imdbRating = show.imdbRating
        self.rottenTomatoesRating = show.rottenTomatoesRating
        self.cachedAt = Date()
    }

    var isExpired: Bool {
        Date().timeIntervalSince(cachedAt) > 86400
    }
}
