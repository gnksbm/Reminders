//
//  HashTag.swift
//  Reminders
//
//  Created by gnksbm on 7/2/24.
//

import Foundation

import RealmSwift

final class HashTag: Object {
    @Persisted(originProperty: "hashTag")
    var linkingObjects: LinkingObjects<TodoItem>
    
    @Persisted(primaryKey: true) var name: String
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
