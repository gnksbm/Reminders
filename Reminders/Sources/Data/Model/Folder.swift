//
//  Folder.swift
//  Reminders
//
//  Created by gnksbm on 7/8/24.
//

import Foundation

import RealmSwift

final class Folder: Object {
    @Persisted var items: List<TodoItem>
}
