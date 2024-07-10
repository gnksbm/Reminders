//
//  View.swift
//  SeSAC5MVVMBasic
//
//  Created by gnksbm on 7/10/24.
//

import Foundation

protocol View: AnyObject {
    associatedtype ViewModelObject: ViewModel
    
    var viewModel: ViewModelObject? { get set }
    
    func bind(viewModel: ViewModelObject)
}

extension View {
    var viewModel: ViewModelObject? {
        get {
            ViewModelStorage.storage.value(key: self) as? ViewModelObject
        }
        set {
            ViewModelStorage.storage.setValue(
                key: self,
                value: newValue
            )
            if let newValue {
                bind(viewModel: newValue)
            }
        }
    }
}
