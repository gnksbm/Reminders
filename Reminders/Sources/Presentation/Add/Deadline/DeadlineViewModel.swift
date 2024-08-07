//
//  DeadlineViewModel.swift
//  Reminders
//
//  Created by gnksbm on 7/9/24.
//

import Foundation

final class DeadlineViewModel: ViewModel {
    weak var delegate: DeadlineViewModelDelegate?
    
    func transform(input: Input) -> Output {
        let output = Output()
        input.dateButtonTapEvent.bind { [weak self] selectedDate in
            guard let self else { return }
            delegate?.deadlineDidSelected(date: selectedDate)
        }
        return output
    }
}

extension DeadlineViewModel {
    struct Input {
        let dateButtonTapEvent: Observable<Date>
    }
    
    struct Output { }
}

protocol DeadlineViewModelDelegate: AnyObject {
    func deadlineDidSelected(date: Date)
}
