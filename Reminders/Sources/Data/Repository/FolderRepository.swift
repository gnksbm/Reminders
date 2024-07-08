//
//  FolderRepository.swift
//  Reminders
//
//  Created by gnksbm on 7/8/24.
//

import UIKit

import RealmSwift

final class FolderRepository {
    private let realmStorage = RealmStorage.shared
    static let shared = FolderRepository()
    
    private init() { }
    
    func addNewFolder(folder: Folder) throws { 
        try realmStorage.create(folder)
    }
    
    func fetchFolders() -> [Folder] {
        Array(realmStorage.read(Folder.self))
    }
    
    func addTodoInFolder(_ item: TodoItem, folder: Folder) throws {
        try realmStorage.update(folder) {
            $0.items.append(item)
        }
    }
    
    func updateFolder(
        item: Folder,
        _ block: (Folder) -> Void
    ) throws {
        try realmStorage.update(item, block)
    }
    
    func removeFolder(_ folder: Folder) throws {
        try realmStorage.delete(folder)
    }
}

