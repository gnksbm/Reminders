//
//  Folder.swift
//  Reminders
//
//  Created by gnksbm on 7/8/24.
//

import Foundation

import RealmSwift

final class Folder: Object {
    /// RealmVersion.folderNameAdded 버전에서 추가
    @Persisted var name: String
    @Persisted var items: List<TodoItem>
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
