//
//  SummaryViewModel.swift
//  Reminders
//
//  Created by gnksbm on 7/10/24.
//

import Foundation

final class SummaryViewModel: ViewModel {
    private let todoRepository = TodoRepository.shared
    
    func transform(input: Input) -> Output {
        let output = Output(
            todoItems: Observable<[TodoItem]>([]),
            startDetailFlow: 
                Observable<SummaryViewController.CollectionViewItem?>(nil),
            startCalendarFlow: Observable<Void>(()),
            startFolderFlow: Observable<Void>(()),
            startAddFlow: Observable<Void>(())
        )
        
        todoRepository.dataChangeEvent.bind { [weak self] _ in
            guard let self else { return }
            let items = todoRepository.fetchItems()
            output.todoItems.onNext(items)
        }
        
        input.viewDidLoadEvent.bind { [weak self] _ in
            guard let self else { return }
            let items = todoRepository.fetchItems()
            output.todoItems.onNext(items)
        }
        
        input.calendarButtonTapEvent.bind { _ in
            output.startCalendarFlow.onNext(())
        }
        
        input.folderButtonTapEvent.bind { _ in
            output.startFolderFlow.onNext(())
        }
        
        input.itemSelectEvent.bind { item in
            output.startDetailFlow.onNext(item)
        }
        
        input.addButtonTapEvent.bind { _ in
            output.startAddFlow.onNext(())
        }
        
        return output
    }
}

extension SummaryViewModel {
    struct Input {
        let viewDidLoadEvent: Observable<Void>
        let calendarButtonTapEvent: Observable<Void>
        let folderButtonTapEvent: Observable<Void>
        let itemSelectEvent: 
        Observable<SummaryViewController.CollectionViewItem?>
        let addButtonTapEvent: Observable<Void>
    }
    
    struct Output {
        let todoItems: Observable<[TodoItem]>
        let startDetailFlow:
        Observable<SummaryViewController.CollectionViewItem?>
        let startCalendarFlow: Observable<Void>
        let startFolderFlow: Observable<Void>
        let startAddFlow: Observable<Void>
    }
}
