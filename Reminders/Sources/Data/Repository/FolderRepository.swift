//
//  FolderRepository.swift
//  Reminders
//
//  Created by gnksbm on 7/8/24.
//

import UIKit

import RealmSwift

final class FolderRepository {
    static let shared = FolderRepository()
    
    private let realmStorage = RealmStorage.shared
    private let imageStorage = ImageStorage.shared
    
    private init() { }
    
    func addNewFolder(folder: Folder) throws {
        try realmStorage.create(folder)
    }
    
    func fetchFolders() -> [Folder] {
        Array(realmStorage.read(Folder.self))
    }
    
    func addTodoInFolder(
        _ item: TodoItem,
        folder: Folder,
        images: [UIImage]
    ) throws {
        let imageFileNames = try imageStorage.addImages(images)
        item.imageFileName.append(objectsIn: imageFileNames)
        try updateFolder(item: folder) {
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
