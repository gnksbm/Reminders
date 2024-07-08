//
//  TodoRepository.swift
//  Reminders
//
//  Created by gnksbm on 7/5/24.
//

import UIKit

import RealmSwift

final class TodoRepository {
    private let realmStorage = RealmStorage.shared
    private let imageStorage = ImageStorage.shared
    
    static let shared = TodoRepository()
    
    private init() { }
    
    func addNewTodo(item: TodoItem, images: [UIImage]) throws {
        let imageFileNames = try imageStorage.addImages(images)
        item.imageFileName.append(objectsIn: imageFileNames)
        try realmStorage.create(item)
    }
    
    func fetchItems() -> [TodoItem] {
        Array(realmStorage.read(TodoItem.self))
    }
    
    func update(
        item: TodoItem,
        _ block: (TodoItem) -> Void
    ) throws {
        try realmStorage.update(item, block)
    }
    
    func removeTodo(item: TodoItem) throws {
        try imageStorage.removeImages(fileNames: Array(item.imageFileName))
        try realmStorage.delete(item)
    }
}
