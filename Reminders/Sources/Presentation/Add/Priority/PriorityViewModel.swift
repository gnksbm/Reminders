//
//  PriorityViewModel.swift
//  Reminders
//
//  Created by gnksbm on 7/9/24.
//

import Foundation

final class PriorityViewModel: ViewModel {
    weak var delegate: PriorityViewModelDelegate?
    
    func transform(input: Input) -> Output {
        let output = Output()
        input.segmentControlChangeEvent.bind { [weak self] index in
            self?.delegate?.priorityDidChanged(index: index)
        }
        return output
    }
}

extension PriorityViewModel {
    struct Input {
        let segmentControlChangeEvent: Observable<Int>
    }
    struct Output { }
}

protocol PriorityViewModelDelegate: AnyObject {
    func priorityDidChanged(index: Int)
}
