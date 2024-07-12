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
    
    private var title: String?
    private var memo: String?
    private let date = Observable<Date?>(nil)
    private let hashTagStr = Observable<String?>(nil)
    private let priority = Observable<TodoItem.Priority>(.none)
    private let images = Observable<[UIImage]>([])
    private let folder = Observable<Folder?>(nil)
    private let imageSelectedEvent = Observable<Void>(())
    
    func transform(input: Input) -> Output {
        let output = Output(
            deadline: date,
            hashTag: hashTagStr,
            priority: priority,
            images: images,
            folder: folder,
            imageDidSelected: imageSelectedEvent,
            errorMessage: Observable(""), 
            startFlow: Observable(nil),
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
        
        input.navigationButtonTapEvent.bind { eventTpye in
            output.startFlow.onNext(eventTpye)
        }
        
        return output
    }
    
    func folderSelected(folder: Folder) {
        self.folder.onNext(folder)
    }
    
    private func createAndSave(output: Output) throws {
        guard let title else { throw AddViewModelError.emptyTitle }
        var hashTag: HashTag?
        if let hashTagStr = output.hashTag.value() {
            hashTag = hashTagRepository.findOrInitialize(tagName: hashTagStr)
        }
        let todoItem = TodoItem(
            title: title,
            memo: memo,
            deadline: output.deadline.value(),
            hashTag: hashTag,
            priority: output.priority.value(),
            folder: output.folder.value()
        )
        try todoRepository.addNewTodo(
            item: todoItem,
            images: output.images.value()
        )
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

extension AddViewModel: PriorityViewModelDelegate {
    func priorityDidChanged(index: Int) {
        priority.onNext(TodoItem.Priority.allCases[index])
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
        let navigationButtonTapEvent: Observable<NavigationEventType?>
    }
    
    struct Output {
        let deadline: Observable<Date?>
        let hashTag: Observable<String?>
        let priority: Observable<TodoItem.Priority>
        let images: Observable<[UIImage]>
        let folder: Observable<Folder?>
        let imageDidSelected: Observable<Void>
        let errorMessage: Observable<String>
        let startFlow: Observable<NavigationEventType?>
        let flowFinished: Observable<Void>
    }
}

enum NavigationEventType: Int, CaseIterable {
    case deadline, hashTag, priority, image, folder
    
    var title: String {
        switch self {
        case .deadline:
            "마감일"
        case .hashTag:
            "태그"
        case .priority:
            "우선순위"
        case .image:
            "이미지 추가"
        case .folder:
            "저장할 폴더"
        }
    }
}
