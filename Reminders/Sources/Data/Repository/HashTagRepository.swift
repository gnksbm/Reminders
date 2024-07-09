//
//  HashTagRepository.swift
//  Reminders
//
//  Created by gnksbm on 7/9/24.
//

import Foundation

final class HashTagRepository {
    static let shared = HashTagRepository()
    
    private let realmStorage = RealmStorage.shared
    
    private init() { }
    
    func findOrInitialize(tagName: String) -> HashTag {
        realmStorage.read(HashTag.self).first { $0.name == tagName } ??
        HashTag(name: tagName)
    }
}
