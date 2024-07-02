//
//  TodoItem.swift
//  Reminders
//
//  Created by gnksbm on 7/2/24.
//

import Foundation

import RealmSwift

final class TodoItem: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String
    @Persisted var memo: String?
    @Persisted var deadline: Date?
    @Persisted var hashTag: HashTag?
    @Persisted var priority: Priority
    @Persisted var imageData: List<Data>
    @Persisted var isDone: Bool
    
    convenience init(
        title: String,
        memo: String? = nil,
        deadline: Date? = nil,
        hashTag: HashTag? = nil,
        priority: Priority,
        imageData: List<Data>
    ) {
        self.init()
        self.id = id
        self.title = title
        self.memo = memo
        self.deadline = deadline
        self.hashTag = hashTag
        self.priority = priority
        self.imageData = imageData
        self.isDone = false
    }
}

extension TodoItem {
    enum Priority: String, PersistableEnum {
        case low = "낮음"
        case mid = "중간"
        case high = "높음"
        case none = "없음"
    }
}
