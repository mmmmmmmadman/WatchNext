import Foundation
import SwiftData

@MainActor
class CacheService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func cacheMovie(_ movie: Movie) {
        let cachedMovie = CachedMovie(from: movie)
        modelContext.insert(cachedMovie)
        try? modelContext.save()
    }

    func cacheMovies(_ movies: [Movie]) {
        for movie in movies {
            let cachedMovie = CachedMovie(from: movie)
            modelContext.insert(cachedMovie)
        }
        try? modelContext.save()
    }

    func getCachedMovie(id: Int) -> CachedMovie? {
        let descriptor = FetchDescriptor<CachedMovie>(
            predicate: #Predicate { $0.id == id }
        )
        return try? modelContext.fetch(descriptor).first
    }

    func getCachedMovies(genreId: Int? = nil) -> [CachedMovie] {
        var descriptor = FetchDescriptor<CachedMovie>(
            sortBy: [SortDescriptor(\.cachedAt, order: .reverse)]
        )

        if let genreId = genreId {
            descriptor.predicate = #Predicate { movie in
                movie.genreIds.contains(genreId)
            }
        }

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func cacheTVShow(_ show: TVShow) {
        let cachedShow = CachedTVShow(from: show)
        modelContext.insert(cachedShow)
        try? modelContext.save()
    }

    func cacheTVShows(_ shows: [TVShow]) {
        for show in shows {
            let cachedShow = CachedTVShow(from: show)
            modelContext.insert(cachedShow)
        }
        try? modelContext.save()
    }

    func getCachedTVShow(id: Int) -> CachedTVShow? {
        let descriptor = FetchDescriptor<CachedTVShow>(
            predicate: #Predicate { $0.id == id }
        )
        return try? modelContext.fetch(descriptor).first
    }

    func getCachedTVShows(genreId: Int? = nil) -> [CachedTVShow] {
        var descriptor = FetchDescriptor<CachedTVShow>(
            sortBy: [SortDescriptor(\.cachedAt, order: .reverse)]
        )

        if let genreId = genreId {
            descriptor.predicate = #Predicate { show in
                show.genreIds.contains(genreId)
            }
        }

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func clearExpiredCache() {
        let expirationDate = Date().addingTimeInterval(-Constants.Cache.expirationInterval)

        let movieDescriptor = FetchDescriptor<CachedMovie>(
            predicate: #Predicate { $0.cachedAt < expirationDate }
        )
        if let expiredMovies = try? modelContext.fetch(movieDescriptor) {
            for movie in expiredMovies {
                modelContext.delete(movie)
            }
        }

        let showDescriptor = FetchDescriptor<CachedTVShow>(
            predicate: #Predicate { $0.cachedAt < expirationDate }
        )
        if let expiredShows = try? modelContext.fetch(showDescriptor) {
            for show in expiredShows {
                modelContext.delete(show)
            }
        }

        try? modelContext.save()
    }

    func clearAllCache() {
        try? modelContext.delete(model: CachedMovie.self)
        try? modelContext.delete(model: CachedTVShow.self)
        try? modelContext.save()
    }
}
