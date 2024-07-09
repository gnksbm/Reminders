//
//  TagViewModel.swift
//  Reminders
//
//  Created by gnksbm on 7/9/24.
//

import Foundation

final class TagViewModel: ViewModel {
    weak var delegate: TagViewModelDelegate?
    
    func transform(input: Input) -> Output {
        let output = Output()
        input.textChangeEvent.bind { [weak self] hashTag in
            self?.delegate?.hashTagDidChanged(hashTag: hashTag)
        }
        return output
    }
}

extension TagViewModel {
    struct Input { 
        let textChangeEvent: Observable<String?>
    }
    struct Output { }
}

protocol TagViewModelDelegate: AnyObject {
    func hashTagDidChanged(hashTag: String?)
}
