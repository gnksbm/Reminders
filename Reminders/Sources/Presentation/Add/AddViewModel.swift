//
//  AddViewModel.swift
//  Reminders
//
//  Created by gnksbm on 7/9/24.
//

import UIKit
import PhotosUI

final class AddViewModel: ViewModel {
    private let hashTagRepository = HashTagRepository.shared
    private let folderRepository = FolderRepository.shared
    private let todoRepository = TodoRepository.shared
    
    var title: String?
    var memo: String?
    let date = Observable<Date?>(nil)
    let hashTagStr = Observable<String?>(nil)
    let images = Observable<[UIImage]>([])
    let imageSelectedEvent = Observable<Void>(())
    
    func transform(input: Input) -> Output {
        let output = Output(
            selectedDate: date,
            hashTagStr: hashTagStr,
            priority: Observable(.none),
            selectedImages: images,
            imageSelected: imageSelectedEvent,
            folder: Observable(nil),
            errorMessage: Observable(""),
            flowFinished: Observable(())
        )
        input.titleInputEvent.bind { [weak self] title in
            self?.title = title
        }
        input.memoInputEvent.bind { [weak self] memo in
            self?.memo = memo
        }
        input.saveButtonTapEvent.bind { [weak self] _ in
            guard let self else { return }
            do {
                try createAndSave(output: output)
                output.flowFinished.onNext(())
            } catch {
                output.errorMessage.onNext(error.localizedDescription)
                Logger.error(error)
            }
        }
        input.cancelButtonTapEvent.bind { _ in
            output.flowFinished.onNext(())
        }
        return output
    }
    
    func createAndSave(output: Output) throws {
        guard let title else { throw AddViewModelError.emptyTitle }
        var hashTag: HashTag?
        if let hashTagStr = output.hashTagStr.value() {
            hashTag = hashTagRepository.findOrInitialize(tagName: hashTagStr)
        }
        let todoItem = TodoItem(
            title: title,
            memo: memo,
            deadline: output.selectedDate.value(),
            hashTag: hashTag,
            priority: output.priority.value()
        )
        if let folder = output.folder.value() {
            try folderRepository.addTodoInFolder(
                todoItem,
                folder: folder,
                images: output.selectedImages.value()
            )
        } else {
            try todoRepository.addNewTodo(
                item: todoItem,
                images: output.selectedImages.value()
            )
        }
    }
}

enum AddViewModelError: LocalizedError {
    case emptyTitle
    
    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "제목을 입력해주세요"
        }
    }
}

extension AddViewModel: DeadlineViewModelDelegate {
    func deadlineDidSelected(date: Date) {
        self.date.onNext(date)
    }
}

extension AddViewModel: TagViewModelDelegate {
    func hashTagDidChanged(hashTag: String?) {
        hashTagStr.onNext(hashTag)
    }
}

extension AddViewModel: PHPickerViewControllerDelegate {
    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {
        let group = DispatchGroup()
        images.onNext([])
        var selectedImages = [UIImage]()
        results.map(\.itemProvider)
            .filter { $0.canLoadObject(ofClass: UIImage.self) }
            .forEach {
                group.enter()
                $0.loadObject(
                    ofClass: UIImage.self
                ) { item, error in
                    if let error {
                        Logger.error(error)
                        return
                    }
                    if let image = item as? UIImage {
                        selectedImages.append(image)
                    }
                    group.leave()
                }
            }
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            images.onNext(selectedImages)
        }
        imageSelectedEvent.onNext(())
    }
}

extension AddViewModel {
    struct Input {
        let titleInputEvent: Observable<String?>
        let memoInputEvent: Observable<String?>
        let saveButtonTapEvent: Observable<Void>
        let cancelButtonTapEvent: Observable<Void>
    }
    
    struct Output {
        let selectedDate: Observable<Date?>
        let hashTagStr: Observable<String?>
        let priority: Observable<TodoItem.Priority>
        let selectedImages: Observable<[UIImage]>
        let imageSelected: Observable<Void>
        let folder: Observable<Folder?>
        let errorMessage: Observable<String>
        let flowFinished: Observable<Void>
    }
}
