//
//  RealmStorage.swift
//  Reminders
//
//  Created by gnksbm on 7/2/24.
//

import Foundation

import RealmSwift

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

extension RealmStorage {
    static let shared = RealmStorage()
}

extension RealmStorage: PersistenceStorage {
    typealias StorableObject = Object
    typealias FetchResult = Results<Object>
}

