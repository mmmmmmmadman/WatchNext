import Foundation
import SwiftData
import CloudKit

actor SyncService {
    static let shared = SyncService()

    private let cloudKitService = CloudKitService.shared
    private var isSyncing = false

    private init() {}

    // MARK: - Sync Operations

    func performSync(modelContext: ModelContext) async throws {
        guard !isSyncing else { return }

        // Check if CloudKit is available before attempting sync
        guard await cloudKitService.isAvailable else {
            // CloudKit not available, skip sync silently
            return
        }

        isSyncing = true
        defer { isSyncing = false }

        let accountStatus = try await cloudKitService.checkAccountStatus()
        guard accountStatus == .available else {
            throw SyncError.notAuthenticated
        }

        try await uploadPendingItems(modelContext: modelContext)
        try await deletePendingItems(modelContext: modelContext)
        try await downloadAndMerge(modelContext: modelContext)
    }

    func performInitialSync(modelContext: ModelContext) async throws {
        guard !isSyncing else { return }

        // Check if CloudKit is available before attempting sync
        guard await cloudKitService.isAvailable else {
            // CloudKit not available, skip sync silently
            return
        }

        isSyncing = true
        defer { isSyncing = false }

        let accountStatus = try await cloudKitService.checkAccountStatus()
        guard accountStatus == .available else {
            throw SyncError.notAuthenticated
        }

        try await markLocalItemsForUpload(modelContext: modelContext)
        try await uploadPendingItems(modelContext: modelContext)
        try await downloadAndMerge(modelContext: modelContext)
    }

    // MARK: - Upload

    private func uploadPendingItems(modelContext: ModelContext) async throws {
        let pendingUpload = SyncStatus.pendingUpload.rawValue
        let local = SyncStatus.local.rawValue
        let descriptor = FetchDescriptor<FavoriteItem>(
            predicate: #Predicate { $0.syncStatusRaw == pendingUpload || $0.syncStatusRaw == local }
        )

        let items = try modelContext.fetch(descriptor)

        for item in items {
            do {
                let record: CKRecord
                if item.cloudRecordId != nil {
                    record = try await cloudKitService.update(item)
                } else {
                    record = try await cloudKitService.save(item)
                }

                await MainActor.run {
                    item.cloudRecordId = record.recordID.recordName
                    item.syncStatus = .synced
                }
            } catch {
                print("Failed to upload item \(item.id): \(error)")
            }
        }

        try await MainActor.run {
            try modelContext.save()
        }
    }

    // MARK: - Delete

    private func deletePendingItems(modelContext: ModelContext) async throws {
        let pendingDelete = SyncStatus.pendingDelete.rawValue
        let descriptor = FetchDescriptor<FavoriteItem>(
            predicate: #Predicate { $0.syncStatusRaw == pendingDelete }
        )

        let items = try modelContext.fetch(descriptor)

        for item in items {
            if let recordId = item.cloudRecordId {
                do {
                    try await cloudKitService.delete(recordId: recordId)
                } catch {
                    print("Failed to delete item from cloud \(item.id): \(error)")
                }
            }

            await MainActor.run {
                modelContext.delete(item)
            }
        }

        try await MainActor.run {
            try modelContext.save()
        }
    }

    // MARK: - Download and Merge

    private func downloadAndMerge(modelContext: ModelContext) async throws {
        let cloudRecords = try await cloudKitService.fetchAll()

        let descriptor = FetchDescriptor<FavoriteItem>()
        let localItems = try modelContext.fetch(descriptor)

        let localByTmdbId: [String: FavoriteItem] = Dictionary(
            uniqueKeysWithValues: localItems.map { ("\($0.tmdbId)-\($0.mediaType.rawValue)", $0) }
        )

        for record in cloudRecords {
            guard let cloudItem = await cloudKitService.favoriteItem(from: record) else { continue }

            let key = "\(cloudItem.tmdbId)-\(cloudItem.mediaType.rawValue)"

            if let localItem = localByTmdbId[key] {
                if cloudItem.lastModified > localItem.lastModified {
                    await MainActor.run {
                        localItem.title = cloudItem.title
                        localItem.posterPath = cloudItem.posterPath
                        localItem.releaseYear = cloudItem.releaseYear
                        localItem.lastModified = cloudItem.lastModified
                        localItem.cloudRecordId = cloudItem.cloudRecordId
                        localItem.syncStatus = .synced
                    }
                }
            } else {
                await MainActor.run {
                    modelContext.insert(cloudItem)
                }
            }
        }

        try await MainActor.run {
            try modelContext.save()
        }
    }

    // MARK: - Helpers

    private func markLocalItemsForUpload(modelContext: ModelContext) async throws {
        let local = SyncStatus.local.rawValue
        let descriptor = FetchDescriptor<FavoriteItem>(
            predicate: #Predicate { $0.syncStatusRaw == local }
        )

        let items = try modelContext.fetch(descriptor)

        for item in items {
            await MainActor.run {
                item.syncStatus = .pendingUpload
            }
        }

        try await MainActor.run {
            try modelContext.save()
        }
    }

    // MARK: - Delete All Cloud Data

    func deleteAllCloudData() async throws {
        guard await cloudKitService.isAvailable else {
            // CloudKit not available, nothing to delete
            return
        }
        try await cloudKitService.deleteAll()
    }
}

enum SyncError: LocalizedError {
    case notAuthenticated
    case syncInProgress
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in to iCloud to sync your favorites"
        case .syncInProgress:
            return "Sync is already in progress"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
