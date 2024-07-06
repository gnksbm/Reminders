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
    static let shared = TodoRepository()
    
    private let imageStorage = ImageStorage.shared
    
    private init() { }
    
    func addNewTodo(item: TodoItem, images: [UIImage]) throws {
        let imageFileNames = try imageStorage.addImages(images)
        item.imageFileName.append(objectsIn: imageFileNames)
        try realmStorage.create(item)
    }
    
    func fetchItems() -> [TodoItem] {
        Array(realmStorage.read(TodoItem.self))
    }
    
    func update<T>(
        item: TodoItem,
        willChange: [ReferenceWritableKeyPath<TodoItem, T> : T]
    ) throws {
        try realmStorage.update(item, willChange: willChange)
    }
    
    func removeTodo(item: TodoItem) throws {
        try imageStorage.removeImages(fileNames: Array(item.imageFileName))
        try realmStorage.delete(item)
    }
}
