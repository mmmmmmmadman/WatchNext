import Foundation
import CloudKit

actor CloudKitService {
    static let shared = CloudKitService()

    private let containerIdentifier = "iCloud.com.madzine.WatchNext"
    private let recordType = "FavoriteItem"

    private var _container: CKContainer?
    private var _isAvailable: Bool?
    private var _checkedEntitlements = false

    private var hasCloudKitEntitlements: Bool {
        // Check if CloudKit entitlements are available by checking if iCloud is configured
        // This avoids crashing when CKContainer is initialized without entitlements
        #if os(iOS)
        // On iOS, check if ubiquity identity token exists (indicates iCloud is set up)
        return FileManager.default.ubiquityIdentityToken != nil
        #else
        // On macOS, we have entitlements configured
        return true
        #endif
    }

    private var container: CKContainer? {
        guard hasCloudKitEntitlements else { return nil }

        if _container == nil {
            _container = CKContainer(identifier: containerIdentifier)
        }
        return _container
    }

    private var privateDatabase: CKDatabase? {
        container?.privateCloudDatabase
    }

    private init() {}

    var isAvailable: Bool {
        get async {
            if let cached = _isAvailable {
                return cached
            }

            guard hasCloudKitEntitlements else {
                _isAvailable = false
                return false
            }

            guard let container = container else {
                _isAvailable = false
                return false
            }

            do {
                let status = try await container.accountStatus()
                let available = status == .available
                _isAvailable = available
                return available
            } catch {
                _isAvailable = false
                return false
            }
        }
    }

    // MARK: - CRUD Operations

    func save(_ item: FavoriteItem) async throws -> CKRecord {
        guard let privateDatabase = privateDatabase else {
            throw CloudKitError.notAvailable
        }

        let record = CKRecord(recordType: recordType)
        record["tmdbId"] = item.tmdbId as CKRecordValue
        record["mediaType"] = item.mediaType.rawValue as CKRecordValue
        record["title"] = item.title as CKRecordValue
        record["posterPath"] = item.posterPath as CKRecordValue?
        record["releaseYear"] = item.releaseYear as CKRecordValue?
        record["addedAt"] = item.addedAt as CKRecordValue
        record["lastModified"] = item.lastModified as CKRecordValue
        record["localId"] = item.id.uuidString as CKRecordValue

        return try await privateDatabase.save(record)
    }

    func update(_ item: FavoriteItem) async throws -> CKRecord {
        guard let privateDatabase = privateDatabase else {
            throw CloudKitError.notAvailable
        }

        guard let recordIdString = item.cloudRecordId else {
            throw CloudKitError.missingRecordId
        }
        let recordId = CKRecord.ID(recordName: recordIdString)

        let record = try await privateDatabase.record(for: recordId)
        record["tmdbId"] = item.tmdbId as CKRecordValue
        record["mediaType"] = item.mediaType.rawValue as CKRecordValue
        record["title"] = item.title as CKRecordValue
        record["posterPath"] = item.posterPath as CKRecordValue?
        record["releaseYear"] = item.releaseYear as CKRecordValue?
        record["lastModified"] = item.lastModified as CKRecordValue

        return try await privateDatabase.save(record)
    }

    func delete(recordId: String) async throws {
        guard let privateDatabase = privateDatabase else {
            throw CloudKitError.notAvailable
        }

        let id = CKRecord.ID(recordName: recordId)
        try await privateDatabase.deleteRecord(withID: id)
    }

    func fetchAll() async throws -> [CKRecord] {
        guard let privateDatabase = privateDatabase else {
            throw CloudKitError.notAvailable
        }

        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "addedAt", ascending: false)]

        var allRecords: [CKRecord] = []
        var cursor: CKQueryOperation.Cursor?

        repeat {
            let result: (matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?)

            if let cursor = cursor {
                result = try await privateDatabase.records(continuingMatchFrom: cursor)
            } else {
                result = try await privateDatabase.records(matching: query)
            }

            for (_, recordResult) in result.matchResults {
                if let record = try? recordResult.get() {
                    allRecords.append(record)
                }
            }

            cursor = result.queryCursor
        } while cursor != nil

        return allRecords
    }

    func deleteAll() async throws {
        guard let privateDatabase = privateDatabase else {
            throw CloudKitError.notAvailable
        }

        let records = try await fetchAll()
        let recordIds = records.map { $0.recordID }

        guard !recordIds.isEmpty else { return }

        let result = try await privateDatabase.modifyRecords(saving: [], deleting: recordIds)
        _ = result
    }

    // MARK: - Conversion

    func favoriteItem(from record: CKRecord) -> FavoriteItem? {
        guard let tmdbId = record["tmdbId"] as? Int,
              let mediaTypeString = record["mediaType"] as? String,
              let mediaType = MediaType(rawValue: mediaTypeString),
              let title = record["title"] as? String,
              let addedAt = record["addedAt"] as? Date,
              let lastModified = record["lastModified"] as? Date else {
            return nil
        }

        let localIdString = record["localId"] as? String
        let id = localIdString.flatMap { UUID(uuidString: $0) } ?? UUID()

        return FavoriteItem(
            id: id,
            tmdbId: tmdbId,
            mediaType: mediaType,
            title: title,
            posterPath: record["posterPath"] as? String,
            releaseYear: record["releaseYear"] as? Int,
            addedAt: addedAt,
            syncStatus: .synced,
            cloudRecordId: record.recordID.recordName,
            lastModified: lastModified
        )
    }

    // MARK: - Account Status

    func checkAccountStatus() async throws -> CKAccountStatus {
        guard let container = container else {
            throw CloudKitError.notAvailable
        }
        return try await container.accountStatus()
    }
}

enum CloudKitError: LocalizedError {
    case notAvailable
    case missingRecordId
    case notAuthenticated
    case networkUnavailable
    case serverError(Error)

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "CloudKit is not available"
        case .missingRecordId:
            return "Missing CloudKit record ID"
        case .notAuthenticated:
            return "Not signed in to iCloud"
        case .networkUnavailable:
            return "Network unavailable"
        case .serverError(let error):
            return error.localizedDescription
        }
    }
}
