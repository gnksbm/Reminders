//
//  PersistenceStorage.swift
//  Reminders
//
//  Created by gnksbm on 7/2/24.
//

import Foundation

protocol PersistenceStorage {
    associatedtype StorableObject
    associatedtype FetchResult
    
    func create(_ object: StorableObject) throws
    func read(_ type: StorableObject.Type) -> FetchResult
    func delete(_ object: StorableObject) throws
}
