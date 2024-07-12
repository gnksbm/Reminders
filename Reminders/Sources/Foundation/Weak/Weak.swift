//
//  Weak.swift
//  SeSAC5MVVMBasic
//
//  Created by gnksbm on 7/10/24.
//

import Foundation

final class Weak<Base: AnyObject> {
    weak var base: Base?
    
    private let baseHashValue: Int
    
    init(_ base: Base) {
        self.baseHashValue = ObjectIdentifier(base).hashValue
        self.base = base
    }
}

extension Weak: Hashable {
    static func == (lhs: Weak<Base>, rhs: Weak<Base>) -> Bool {
        lhs.baseHashValue == rhs.baseHashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(baseHashValue)
    }
}
