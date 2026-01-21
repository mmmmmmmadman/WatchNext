import Foundation
import SwiftData

enum SyncStatus: String, Codable {
    case local
    case synced
    case pendingUpload
    case pendingDelete
}

enum MediaType: String, Codable {
    case movie
    case tv
}

@Model
final class FavoriteItem {
    @Attribute(.unique) var id: UUID
    var tmdbId: Int
    var mediaTypeRaw: String
    var title: String
    var posterPath: String?
    var releaseYear: Int?
    var addedAt: Date
    var syncStatusRaw: String
    var cloudRecordId: String?
    var lastModified: Date

    var mediaType: MediaType {
        get { MediaType(rawValue: mediaTypeRaw) ?? .movie }
        set { mediaTypeRaw = newValue.rawValue }
    }

    var syncStatus: SyncStatus {
        get { SyncStatus(rawValue: syncStatusRaw) ?? .local }
        set { syncStatusRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        tmdbId: Int,
        mediaType: MediaType,
        title: String,
        posterPath: String? = nil,
        releaseYear: Int? = nil,
        addedAt: Date = Date(),
        syncStatus: SyncStatus = .local,
        cloudRecordId: String? = nil,
        lastModified: Date = Date()
    ) {
        self.id = id
        self.tmdbId = tmdbId
        self.mediaTypeRaw = mediaType.rawValue
        self.title = title
        self.posterPath = posterPath
        self.releaseYear = releaseYear
        self.addedAt = addedAt
        self.syncStatusRaw = syncStatus.rawValue
        self.cloudRecordId = cloudRecordId
        self.lastModified = lastModified
    }

    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    static func fromMovie(_ movie: Movie) -> FavoriteItem {
        FavoriteItem(
            tmdbId: movie.id,
            mediaType: .movie,
            title: movie.title,
            posterPath: movie.posterPath,
            releaseYear: movie.releaseYear
        )
    }

    static func fromTVShow(_ show: TVShow) -> FavoriteItem {
        FavoriteItem(
            tmdbId: show.id,
            mediaType: .tv,
            title: show.name,
            posterPath: show.posterPath,
            releaseYear: show.firstAirYear
        )
    }
}
