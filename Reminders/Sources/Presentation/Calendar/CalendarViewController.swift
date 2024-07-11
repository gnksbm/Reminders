//
//  CalendarViewController.swift
//  Reminders
//
//  Created by gnksbm on 7/7/24.
//

import UIKit

import FSCalendar
import SnapKit

final class CalendarViewController: BaseViewController, View {
    private lazy var dateSelectEvent = Observable<Date?>(nil)
    
    private lazy var calendarView = FSCalendar().nt.configure {
        $0.delegate(self)
            .scrollDirection(.vertical)
            .scrollEnabled(true)
            .appearance.titleDefaultColor(.label)
    }
    
    override func configureLayout() {
        [calendarView].forEach { view.addSubview($0) }
        
        let safeArea = view.safeAreaLayoutGuide
        
        calendarView.snp.makeConstraints { make in
            make.edges.equalTo(safeArea).inset(20)
        }
    }
    
    func bind(viewModel: CalendarViewModel) {
        let output = viewModel.transform(
            input: CalendarViewModel.Input(
                dateSelectEvent: dateSelectEvent
            )
        )
        output.startListFlow.bind { [weak self] date in
            if let date {
                self?.navigationController?.pushViewController(
                    TodoListViewController { item in
                        item.deadline?.isSameDate(equalTo: date) ?? false
                    },
                    animated: true
                )
            }
        }
    }
}

extension CalendarViewController: FSCalendarDelegate {
    func calendar(
        _ calendar: FSCalendar,
        didSelect date: Date,
        at monthPosition: FSCalendarMonthPosition
    ) {
        dateSelectEvent.onNext(date)
    }
}
