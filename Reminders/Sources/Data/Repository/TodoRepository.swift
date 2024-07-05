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
    
    private let imageStorage = ImageStorage.shared
    
    private init() { }
    
    func addNewTodo(item: TodoItem, images: [UIImage]) throws {
        let imageFileNames = try imageStorage.addImages(images)
        item.imageFileName.append(objectsIn: imageFileNames)
        try RealmStorage.shared.create(item)
    }
    
    func removeTodo(item: TodoItem) throws {
        try imageStorage.removeImages(fileNames: Array(item.imageFileName))
        try RealmStorage.shared.delete(item)
    }
}
