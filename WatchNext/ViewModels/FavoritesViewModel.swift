import Foundation
import SwiftData

@MainActor
@Observable
final class FavoritesViewModel {
    private var modelContext: ModelContext?
    private let syncService = SyncService.shared

    var favorites: [FavoriteItem] = []
    var isLoading = false
    var isSyncing = false
    var errorMessage: String?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadFavorites()
        Task {
            await performSync()
        }
    }

    func performSync() async {
        guard let modelContext, !isSyncing else { return }
        isSyncing = true

        do {
            try await syncService.performSync(modelContext: modelContext)
            loadFavorites()
        } catch {
            // Sync errors are non-fatal, just log them
            print("Sync error: \(error.localizedDescription)")
        }

        isSyncing = false
    }

    func loadFavorites() {
        guard let modelContext else { return }

        let pendingDelete = SyncStatus.pendingDelete.rawValue
        let descriptor = FetchDescriptor<FavoriteItem>(
            predicate: #Predicate { $0.syncStatusRaw != pendingDelete },
            sortBy: [SortDescriptor(\.addedAt, order: .reverse)]
        )

        do {
            favorites = try modelContext.fetch(descriptor)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func isFavorite(tmdbId: Int, mediaType: MediaType) -> Bool {
        favorites.contains { $0.tmdbId == tmdbId && $0.mediaType == mediaType }
    }

    func addFavorite(movie: Movie) {
        guard let modelContext else { return }

        if isFavorite(tmdbId: movie.id, mediaType: .movie) { return }

        let item = FavoriteItem.fromMovie(movie)
        modelContext.insert(item)
        saveAndReload()
    }

    func addFavorite(tvShow: TVShow) {
        guard let modelContext else { return }

        if isFavorite(tmdbId: tvShow.id, mediaType: .tv) { return }

        let item = FavoriteItem.fromTVShow(tvShow)
        modelContext.insert(item)
        saveAndReload()
    }

    func removeFavorite(tmdbId: Int, mediaType: MediaType) {
        guard let modelContext else { return }

        let descriptor = FetchDescriptor<FavoriteItem>(
            predicate: #Predicate<FavoriteItem> { item in
                item.tmdbId == tmdbId
            }
        )

        do {
            let items = try modelContext.fetch(descriptor)
            for item in items where item.mediaType == mediaType {
                if item.syncStatus == .synced {
                    item.syncStatus = .pendingDelete
                    item.lastModified = Date()
                } else {
                    modelContext.delete(item)
                }
            }
            saveAndReload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleFavorite(movie: Movie) {
        if isFavorite(tmdbId: movie.id, mediaType: .movie) {
            removeFavorite(tmdbId: movie.id, mediaType: .movie)
        } else {
            addFavorite(movie: movie)
        }
    }

    func toggleFavorite(tvShow: TVShow) {
        if isFavorite(tmdbId: tvShow.id, mediaType: .tv) {
            removeFavorite(tmdbId: tvShow.id, mediaType: .tv)
        } else {
            addFavorite(tvShow: tvShow)
        }
    }

    func deleteFavorite(_ item: FavoriteItem) {
        guard let modelContext else { return }

        if item.syncStatus == .synced {
            item.syncStatus = .pendingDelete
            item.lastModified = Date()
        } else {
            modelContext.delete(item)
        }
        saveAndReload()
    }

    private func saveAndReload() {
        guard let modelContext else { return }

        do {
            try modelContext.save()
            loadFavorites()
            Task {
                await performSync()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    var movieFavorites: [FavoriteItem] {
        favorites.filter { $0.mediaType == .movie }
    }

    var tvShowFavorites: [FavoriteItem] {
        favorites.filter { $0.mediaType == .tv }
    }
}
