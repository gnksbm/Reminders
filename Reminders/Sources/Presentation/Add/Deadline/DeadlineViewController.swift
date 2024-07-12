//
//  DeadlineViewController.swift
//  Reminders
//
//  Created by gnksbm on 7/3/24.
//

import UIKit

import Neat

final class DeadlineViewController: BaseViewController, View {
    private let viewModel = DeadlineViewModel()
    
    private lazy var dateButtonTapEvent = Observable(datePicker.date)
    
    private lazy var datePicker = UIDatePicker().nt.configure {
        $0.preferredDatePickerStyle(.inline)
            .addTarget(
                self,
                action: #selector(datePickerChanged),
                for: .valueChanged
            )
    }
    
    override func loadView() {
        super.loadView()
        view = datePicker
    }
    
    func bind(viewModel: DeadlineViewModel) {
        _ = viewModel.transform(
            input: DeadlineViewModel.Input(
                dateButtonTapEvent: dateButtonTapEvent
            )
        )
    }
    
    @objc private func datePickerChanged() {
        dateButtonTapEvent.onNext(datePicker.date)
    }
}
