//
//  TodoRepository.swift
//  Reminders
//
//  Created by gnksbm on 7/5/24.
//

import UIKit

import RealmSwift

final class TodoRepository {
    static let shared = TodoRepository()
    
    private let realmStorage = RealmStorage.shared
    private let imageStorage = ImageStorage.shared
    
    let dataChangeEvent = Observable<Void>(())
    
    private init() { }
    
    func addNewTodo(item: TodoItem, images: [UIImage]) throws {
        let imageFileNames = try imageStorage.addImages(images)
        item.imageFileName.append(objectsIn: imageFileNames)
        try realmStorage.create(item)
        dataChangeEvent.onNext(())
    }
    
    func fetchItems() -> [TodoItem] {
        Array(realmStorage.read(TodoItem.self))
    }
    
    func update(
        item: TodoItem,
        _ block: (TodoItem) -> Void
    ) throws {
        try realmStorage.update(item, block)
        dataChangeEvent.onNext(())
    }
    
    func removeTodo(item: TodoItem) throws {
        try imageStorage.removeImages(fileNames: Array(item.imageFileName))
        try realmStorage.delete(item)
        dataChangeEvent.onNext(())
    }
}
