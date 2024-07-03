//
//  NeatCompatible.swift
//  Reminders
//
//  Created by gnksbm on 7/2/24.
//

import Foundation

protocol NeatCompatible { }

extension NeatCompatible where Self: AnyObject {
    var nt: Neat<Self> {
        Neat(self)
    }
}

extension NSObject: NeatCompatible { }
