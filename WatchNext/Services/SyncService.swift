import Foundation
import SwiftData
import CloudKit

/// SyncService 以 @MainActor class 運作，因為主要操作都需要 ModelContext（MainActor bound）。
/// CloudKit 操作透過 await 自動切到 CloudKitService actor。
@MainActor
final class SyncService {
    static let shared = SyncService()

    private let cloudKitService = CloudKitService.shared
    private var isSyncing = false

    private init() {}

    // MARK: - Sync Operations

    func performSync(modelContext: ModelContext) async throws {
        guard !isSyncing else { return }

        // CloudKit 可用性檢查（自動切到 CloudKitService actor）
        guard await cloudKitService.isAvailable else {
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

        guard await cloudKitService.isAvailable else {
            return
        }

        isSyncing = true
        defer { isSyncing = false }

        let accountStatus = try await cloudKitService.checkAccountStatus()
        guard accountStatus == .available else {
            throw SyncError.notAuthenticated
        }

        markLocalItemsForUpload(modelContext: modelContext)
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

                // 已在 MainActor 上，直接修改
                item.cloudRecordId = record.recordID.recordName
                item.syncStatus = .synced
            } catch {
                print("Failed to upload item \(item.id): \(error)")
            }
        }

        try modelContext.save()
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

            // 已在 MainActor 上，直接刪除
            modelContext.delete(item)
        }

        try modelContext.save()
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
                    // 已在 MainActor 上，直接修改
                    localItem.title = cloudItem.title
                    localItem.posterPath = cloudItem.posterPath
                    localItem.releaseYear = cloudItem.releaseYear
                    localItem.lastModified = cloudItem.lastModified
                    localItem.cloudRecordId = cloudItem.cloudRecordId
                    localItem.syncStatus = .synced
                }
            } else {
                modelContext.insert(cloudItem)
            }
        }

        try modelContext.save()
    }

    // MARK: - Helpers

    private func markLocalItemsForUpload(modelContext: ModelContext) {
        let local = SyncStatus.local.rawValue
        let descriptor = FetchDescriptor<FavoriteItem>(
            predicate: #Predicate { $0.syncStatusRaw == local }
        )

        do {
            let items = try modelContext.fetch(descriptor)
            for item in items {
                item.syncStatus = .pendingUpload
            }
            try modelContext.save()
        } catch {
            print("Failed to mark local items for upload: \(error)")
        }
    }

    // MARK: - Delete All Cloud Data

    func deleteAllCloudData() async throws {
        guard await cloudKitService.isAvailable else {
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
