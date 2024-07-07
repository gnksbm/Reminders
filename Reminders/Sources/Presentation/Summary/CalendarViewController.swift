//
//  CalendarViewController.swift
//  Reminders
//
//  Created by gnksbm on 7/7/24.
//

import UIKit

import FSCalendar
import SnapKit

final class CalendarViewController: BaseViewController {
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
}

extension CalendarViewController: FSCalendarDelegate {
    func calendar(
        _ calendar: FSCalendar,
        didSelect date: Date,
        at monthPosition: FSCalendarMonthPosition
    ) {
        navigationController?.pushViewController(
            TodoListViewController { item in
                item.deadline?.isSameDate(equalTo: date) ?? false
            },
            animated: true
        )
    }
}
