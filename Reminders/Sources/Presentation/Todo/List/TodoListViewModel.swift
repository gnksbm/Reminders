//
//  TodoListViewModel.swift
//  Reminders
//
//  Created by gnksbm on 7/11/24.
//

import Foundation

final class TodoListViewModel: ViewModel {
    private var todoRepository = TodoRepository.shared
    private let filter: (TodoItem) -> Bool
    
    init(filter: @escaping (TodoItem) -> Bool) {
        self.filter = filter
    }
    
    func transform(input: Input) -> Output {
        let output = Output(
            todoList: Observable<[TodoItem]>([]),
            startDetailFlow: Observable<TodoItem?>(nil), 
            updateSuccess: Observable<Void>(()),
            updateFailure: Observable<TodoListViewModelError?>(nil)
        )
        
        input.viewDidLoadEvent.bind { [weak self] _ in
            guard let self else { return }
            let todoList = fetchNewList().filter(filter)
            output.todoList.onNext(todoList)
        }
        
        input.sortButtonTapEvent.bind { [weak self] option in
            guard let self,
                  let option else { return }
            let todoList = fetchNewList()
            let filteredList = option.filter(items: todoList)
            output.todoList.onNext(filteredList)
        }
        
        input.itemSelectEvent.bind { item in
            output.startDetailFlow.onNext(item)
        }
        
        input.doneButtonTapEvent.bind { [weak self] item in
            guard let self,
                  let item else { return }
            do {
                try todoRepository.update(item: item) {
                    $0.isDone.toggle()
                }
                output.updateSuccess.onNext(())
            } catch {
                output.updateFailure.onNext(.doneUpdate)
            }
        }
        
        input.starButtonTapEvent.bind { _ in
            // TODO: 즐겨찾기 기능
        }
        
        input.flagButtonTapEvent.bind { [weak self] item in
            guard let self,
                  let item else { return }
            do {
                try todoRepository.update(item: item) {
                    $0.isFlag.toggle()
                }
                output.updateSuccess.onNext(())
            } catch {
                output.updateFailure.onNext(.flagUpdate)
            }
        }
        
        input.removeButtonTapEvent.bind { [weak self] item in
            guard let self,
                  let item else { return }
            do {
                try todoRepository.removeTodo(item: item)
                let todoList = fetchNewList()
                output.todoList.onNext(todoList)
            } catch {
                output.updateFailure.onNext(.removeTodo)
            }
        }
        
        return output
    }
    
    private func fetchNewList() -> [TodoItem] {
        todoRepository.fetchItems().filter(filter)
    }
}

extension TodoListViewModel {
    struct Input {
        let viewDidLoadEvent: Observable<Void>
        let sortButtonTapEvent: Observable<TodoSortOption?>
        let itemSelectEvent: Observable<TodoItem?>
        let doneButtonTapEvent: Observable<TodoItem?>
        let starButtonTapEvent: Observable<TodoItem?>
        let flagButtonTapEvent: Observable<TodoItem?>
        let removeButtonTapEvent: Observable<TodoItem?>
    }
    
    struct Output {
        let todoList: Observable<[TodoItem]>
        let startDetailFlow: Observable<TodoItem?>
        let updateSuccess: Observable<Void>
        let updateFailure: Observable<TodoListViewModelError?>
    }
}

enum TodoListViewModelError: LocalizedError {
    case doneUpdate, flagUpdate, removeTodo
    
    var errorDescription: String? {
        switch self {
        case .doneUpdate:
            "업데이트에 실패했습니다."
        case .flagUpdate:
            "업데이트에 실패했습니다."
        case .removeTodo:
            "제거에 실패했습니다."
        }
    }
}

enum TodoSortOption: CaseIterable {
    case deadline, title, lowPriority
    
    var title: String {
        switch self {
        case .deadline:
            "마감일 순으로 보기"
        case .title:
            "제목 순으로 보기"
        case .lowPriority:
            "우선순위 낮음 만 보기"
        }
    }
    
    func filter(items: [TodoItem]) -> [TodoItem] {
        switch self {
        case .deadline:
            items.sorted { lhs, rhs in
                guard let lhs = lhs.deadline,
                      let rhs = rhs.deadline else { return false }
                return lhs < rhs
            }
        case .title:
            items.sorted { lhs, rhs in
                lhs.title < rhs.title
            }
        case .lowPriority:
            items.filter { $0.priority == .low }
        }
    }
}
