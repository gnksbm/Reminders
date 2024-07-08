//
//  TodoItem.swift
//  Reminders
//
//  Created by gnksbm on 7/2/24.
//

import Foundation

import RealmSwift

final class TodoItem: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String
    @Persisted var memo: String?
    @Persisted var deadline: Date?
    @Persisted var hashTag: HashTag?
    @Persisted var priority: Priority
    @Persisted var imageFileName: List<String>
    @Persisted var isDone: Bool
    @Persisted(originProperty: "items")
    var parentFolder: LinkingObjects<Folder>
    /// RealmVersion.flagAdded 버전에서 추가
    @Persisted var isFlag: Bool
    
    convenience init(
        title: String,
        memo: String? = nil,
        deadline: Date? = nil,
        hashTag: HashTag? = nil,
        priority: Priority
    ) {
        self.init()
        self.id = id
        self.title = title
        self.memo = memo
        self.deadline = deadline
        self.hashTag = hashTag
        self.priority = priority
        self.isDone = false
    }
}

extension TodoItem {
    enum Priority: Int, PersistableEnum {
        case none
        case low
        case mid
        case high
        
        var title: String {
            switch self {
            case .low:
                "낮음"
            case .mid:
                "중간"
            case .high:
                "높음"
            case .none:
                "없음"
            }
        }
    }
}
