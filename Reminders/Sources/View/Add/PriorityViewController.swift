//
//  PriorityViewController.swift
//  Reminders
//
//  Created by gnksbm on 7/3/24.
//

import UIKit

import Neat

final class PriorityViewController: BaseViewController {
    private lazy var segmentControl = UISegmentedControl(
        items: TodoItem.Priority.allCases.map { $0.title }
    ).nt.configure {
        $0.addTarget(
            self,
            action: #selector(segmentDidChanged),
            for: .valueChanged
        )
    }
    
    init(index: Int) {
        super.init()
        segmentControl.selectedSegmentIndex = index
    }
    
    override func configureLayout() {
        [segmentControl].forEach { view.addSubview($0) }
        
        let safeArea = view.safeAreaLayoutGuide
        
        segmentControl.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeArea).inset(20)
//            make.height.equalTo(segmentControl.snp.width).multipliedBy(0.15)
        }
    }
    
    @objc private func segmentDidChanged() {
        NotificationCenter.default.post(
            name: .priority,
            object: nil,
            userInfo: ["priorityIndex": segmentControl.selectedSegmentIndex]
        )
    }
}
