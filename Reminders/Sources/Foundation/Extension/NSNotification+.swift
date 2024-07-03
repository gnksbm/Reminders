//
//  NSNotification+.swift
//  Reminders
//
//  Created by gnksbm on 7/3/24.
//

import Foundation

extension NSNotification.Name {
    static let all = [deadline, hashTag, priority]
    static let deadline = NSNotification.Name("deadline")
    static let hashTag = NSNotification.Name("hashTag")
    static let priority = NSNotification.Name("priority")
}
