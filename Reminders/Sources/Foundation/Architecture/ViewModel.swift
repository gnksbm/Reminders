//
//  ViewModel.swift
//  SeSAC5MVVMBasic
//
//  Created by gnksbm on 7/9/24.
//

import Foundation

protocol ViewModel: AnyObject {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
