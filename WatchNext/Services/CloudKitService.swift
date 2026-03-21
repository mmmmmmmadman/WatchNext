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
        // 先確認 iCloud 帳號存在
        guard FileManager.default.ubiquityIdentityToken != nil else { return false }

        // 再確認 app 實際有 CloudKit entitlement（provisioning profile 有包含）
        guard let entitlements = Bundle.main.infoDictionary else { return false }
        // 如果 CKContainer 初始化曾經失敗，不再嘗試
        if _isAvailable == false { return false }
        return true
    }

    private var container: CKContainer? {
        guard hasCloudKitEntitlements else { return nil }

        if _container == nil {
            var newContainer: CKContainer?
            let success = ObjCExceptionCatcher.execute {
                newContainer = CKContainer(identifier: self.containerIdentifier)
            }

            guard success else {
                print("[CloudKitService] CKContainer init failed")
                _isAvailable = false
                return nil
            }
            _container = newContainer
        }
        return _container
    }

    private var privateDatabase: CKDatabase? {
        container?.privateCloudDatabase
    }

    private init() {}

    /// CloudKit 是否可用，結果會快取。
    /// 所有可能失敗的路徑都安全回傳 false，不會 crash。
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
                // accountStatus() 失敗時安全回傳 false，不丟 error
                print("[CloudKitService] accountStatus check failed: \(error.localizedDescription)")
                _isAvailable = false
                return false
            }
        }
    }

    /// 重設快取，下次存取時重新檢查可用性
    func resetAvailabilityCache() {
        _isAvailable = nil
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
