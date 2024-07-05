//
//  ImageStorage.swift
//  Reminders
//
//  Created by gnksbm on 7/5/24.
//

import UIKit

final class ImageStorage {
    static let shared = ImageStorage()
    
    private let fileManager = FileManager.default
    
    private var documentURL: URL {
        guard let url = fileManager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else { fatalError("Document 경로 찾을 수 없음") }
        return url
    }
    
    private init() { }
    
    func addImages(_ images: [UIImage]) throws -> [String] {
        var imageFileNames = [String]()
        for image in images {
            do {
                let fileName = try addImage(image)
                imageFileNames.append(fileName)
            } catch {
                try imageFileNames.forEach { fileName in
                    try removeImage(fileName: fileName)
                }
                throw error
            }
        }
        return imageFileNames
    }
    
    func removeImages(fileNames: [String]) throws {
        try fileNames.forEach { fileName in
            let fileURL = documentURL.appendingPathComponent(
                fileName,
                conformingTo: .jpeg
            )
            guard let image = UIImage(contentsOfFile: fileURL.path)
            else { return }
            do {
                try removeImage(fileName: fileName)
            } catch {
                try revertImage(image, with: fileName)
                throw error
            }
        }
    }
    
    private func addImage(_ image: UIImage) throws -> String {
        let data = image.jpegData(compressionQuality: 1)
        let fileName = UUID().uuidString
        let fileURL = documentURL.appendingPathComponent(
            fileName,
            conformingTo: .jpeg
        )
        try data?.write(to: fileURL)
        return fileName
    }
    
    private func revertImage(_ image: UIImage, with fileName: String) throws {
        let data = image.jpegData(compressionQuality: 1)
        let fileURL = documentURL.appendingPathComponent(
            fileName,
            conformingTo: .jpeg
        )
        try data?.write(to: fileURL)
    }
    
    private func removeImage(fileName: String) throws {
        let fileURL = documentURL.appendingPathComponent(
            fileName,
            conformingTo: .jpeg
        )
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }
}
