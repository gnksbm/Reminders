//
//  UIEdgeInsets+.swift
//  Reminders
//
//  Created by gnksbm on 7/3/24.
//

import UIKit

extension UIEdgeInsets {
    static func same(equal: CGFloat) -> Self {
        UIEdgeInsets(
            top: equal,
            left: equal,
            bottom: equal,
            right: equal
        )
    }
}
