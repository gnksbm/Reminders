//
//  Date+.swift
//  Reminders
//
//  Created by gnksbm on 7/3/24.
//

import Foundation

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    func isSameDate(equalTo: Date) -> Bool {
        Calendar.current.isDate(self, equalTo: equalTo, toGranularity: .day)
    }
}
