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
    
    func update<T: Object>(
        _ object: T,
        _ block: (T) -> Void
    ) throws {
        try realm.write {
            block(object)
            realm.add(object, update: .modified)
        }
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
        
        case origin, todoFlagAdded, folderNameAdded, folderIDAdded
        
        static func migrate(migration: Migration, version: Int) {
            (version..<latestVersion).forEach { versionNum in
                switch allCases[versionNum] {
                case .origin:
                    migration.enumerateObjects(
                        ofType: TodoItem.className()
                    ) { oldObject, newObject in
                        guard let newObject else { return }
                        newObject["isFlag"] = false
                    }
                case .todoFlagAdded:
                    migration.enumerateObjects(
                        ofType: Folder.className()
                    ) { oldObject, newObject in
                        guard let newObject else { return }
                        newObject["name"] = "이름 없음"
                    }
                case .folderNameAdded:
                    migration.enumerateObjects(
                        ofType: Folder.className()
                    ) {
                        oldObject,
                        newObject in
                        guard let newObject else { return }
                        newObject["id"] = ObjectId.generate()
                    }
                case .folderIDAdded:
                    break
                }
            }
        }
    }
    
    static func migrateIfNeeded() {
        guard let url = Realm.Configuration.defaultConfiguration.fileURL else {
            Logger.debug("Realm 파일 찾을 수 없음")
            return
        }
        do {
            let version = try schemaVersionAtURL(url)
            if version < RealmVersion.latestVersion {
                migrate(currentVersion: Int(version))
            } else {
                Realm.Configuration.defaultConfiguration.schemaVersion = version
            }
        } catch {
            Logger.error(error)
        }
    }
    
    private static func migrate(currentVersion: Int) {
        let config = Realm.Configuration(
            schemaVersion: UInt64(RealmVersion.latestVersion)
        ) { migration, oldSchemaVersion in
            RealmVersion.migrate(
                migration: migration,
                version: Int(oldSchemaVersion)
            )
        }
        Realm.Configuration.defaultConfiguration = config
    }
}

extension RealmStorage {
    static let shared = RealmStorage()
}
