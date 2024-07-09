//
//  ViewModel.swift
//  Reminders
//
//  Created by gnksbm on 7/9/24.
//

import Foundation

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
