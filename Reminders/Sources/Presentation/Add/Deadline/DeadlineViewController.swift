//
//  DeadlineViewController.swift
//  Reminders
//
//  Created by gnksbm on 7/3/24.
//

import UIKit

import Neat

final class DeadlineViewController: BaseViewController {
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
    
    init(vmDelegate: DeadlineViewModelDelegate? = nil) {
        super.init()
        viewModel.delegate = vmDelegate
    }
    
    override func loadView() {
        super.loadView()
        view = datePicker
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    private func bind() {
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
