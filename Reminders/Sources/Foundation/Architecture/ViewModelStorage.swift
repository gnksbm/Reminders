//
//  ViewModelStorage.swift
//  SeSAC5MVVMBasic
//
//  Created by gnksbm on 7/10/24.
//

import Foundation

enum ViewModelStorage {
    typealias View = AnyObject
    typealias ViewModel = AnyObject
    
    static var storage = WeakStorage<View, ViewModel>()
}
