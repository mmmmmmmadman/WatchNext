import Foundation
import SwiftData

struct Movie: Identifiable, Codable {
    let id: Int
    let title: String
    let originalTitle: String
    let overview: String
    let releaseDate: String
    let posterPath: String?
    let backdropPath: String?
    let genreIds: [Int]
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double

    var imdbId: String?
    var imdbRating: Double?
    var rottenTomatoesRating: Int?

    var releaseYear: Int? {
        guard releaseDate.count >= 4 else { return nil }
        return Int(String(releaseDate.prefix(4)))
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
        case id, title, overview, popularity
        case originalTitle = "original_title"
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case genreIds = "genre_ids"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

@Model
final class CachedMovie {
    @Attribute(.unique) var id: Int
    var title: String
    var originalTitle: String
    var overview: String
    var releaseDate: String
    var posterPath: String?
    var genreIds: [Int]
    var voteAverage: Double
    var voteCount: Int
    var imdbId: String?
    var imdbRating: Double?
    var rottenTomatoesRating: Int?
    var cachedAt: Date

    init(from movie: Movie) {
        self.id = movie.id
        self.title = movie.title
        self.originalTitle = movie.originalTitle
        self.overview = movie.overview
        self.releaseDate = movie.releaseDate
        self.posterPath = movie.posterPath
        self.genreIds = movie.genreIds
        self.voteAverage = movie.voteAverage
        self.voteCount = movie.voteCount
        self.imdbId = movie.imdbId
        self.imdbRating = movie.imdbRating
        self.rottenTomatoesRating = movie.rottenTomatoesRating
        self.cachedAt = Date()
    }

    var isExpired: Bool {
        Date().timeIntervalSince(cachedAt) > 86400
    }
}
