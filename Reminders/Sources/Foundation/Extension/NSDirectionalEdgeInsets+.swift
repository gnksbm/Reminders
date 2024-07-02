//
//  NSDirectionalEdgeInsets+.swift
//  Reminders
//
//  Created by gnksbm on 7/2/24.
//

import UIKit

extension NSDirectionalEdgeInsets {
    static func same(equal: CGFloat) -> Self {
        NSDirectionalEdgeInsets(
            top: equal,
            leading: equal,
            bottom: equal,
            trailing: equal
        )
    }
}
