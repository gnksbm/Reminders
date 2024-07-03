//
//  DateViewController.swift
//  Reminders
//
//  Created by gnksbm on 7/3/24.
//

import UIKit

final class DateViewController: BaseViewController {
    private lazy var datePicker = UIDatePicker().nt.configure {
        $0.preferredDatePickerStyle(.inline)
            .addTarget(
                self,
                action: #selector(datePickerChanged),
                for: .valueChanged
            )
    }
    
    init(selectedDate: Date?) {
        super.init()
        if let selectedDate {
            datePicker.date = selectedDate
        }
    }
    
    override func loadView() {
        super.loadView()
        view = datePicker
    }
    
    @objc private func datePickerChanged() {
        NotificationCenter.default.post(
            name: NSNotification.Name("deadline"),
            object: nil,
            userInfo: ["date": datePicker.date]
        )
    }
}
