//
//  TodoDetailViewModel.swift
//  Reminders
//
//  Created by gnksbm on 7/12/24.
//

import Foundation

final class TodoDetailViewModel: ViewModel {
    private let item: TodoItem
    
    init(item: TodoItem) {
        self.item = item
    }
    
    func transform(input: Input) -> Output {
        let output = Output(
            todoItem: Observable<TodoItem?>(nil)
        )
        
        input.viewDidLoadEvent.bind { [weak self] _ in
            output.todoItem.onNext(self?.item)
        }
        
        return output
    }
}

extension TodoDetailViewModel {
    struct Input {
        let viewDidLoadEvent: Observable<Void>
    }
    
    struct Output {
        let todoItem: Observable<TodoItem?>
    }
}
