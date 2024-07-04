//
//  RealmStorage.swift
//  Reminders
//
//  Created by gnksbm on 7/2/24.
//

import Foundation

import RealmSwift

// MARK: CRUD
final class RealmStorage {
    private let realm = try! Realm()
    
    private init() { }
    
    func create(_ object: Object) throws {
        try realm.write {
            realm.add(object)
        }
    }
    
    func read<T: Object>(
        _ type: T.Type
    ) -> Results<T> {
        realm.objects(type)
    }
    
    func delete(_ object: Object) throws {
        try realm.write {
            realm.delete(object)
        }
    }
}

// MARK: 마이그레이션
extension RealmStorage {
    enum RealmVersion: Int, CaseIterable {
        static let latestVersion = RealmVersion.allCases.count - 1
        
        case origin
    }
    
    static func migrationIfNeeded() {
        if let url = try! Realm().configuration.fileURL {
            do {
                let version = try schemaVersionAtURL(url)
                if version == RealmVersion.latestVersion {
                    migration(currentVersion: Int(version))
                }
            } catch {
                Logger.error(error)
            }
        }
    }
    
    private static func migration(currentVersion: Int) {
        let config = Realm.Configuration(
            schemaVersion: UInt64(RealmVersion.latestVersion)
        ) { migration, oldSchemaVersion in
            let currentVersion = RealmVersion.allCases[Int(oldSchemaVersion)]
            switch currentVersion {
            case .origin:
                break
            }
        }
        Realm.Configuration.defaultConfiguration = config
    }
}

extension RealmStorage {
    static let shared = RealmStorage()
}

extension RealmStorage: PersistenceStorage {
    typealias StorableObject = Object
    typealias FetchResult = Results<Object>
}

