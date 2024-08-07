//
//  PriorityViewController.swift
//  Reminders
//
//  Created by gnksbm on 7/3/24.
//

import UIKit

import Neat

final class PriorityViewController: BaseViewController, View {
    private lazy var segmentControlChangeEvent =
    Observable<Int>(segmentControl.selectedSegmentIndex)
    
    private lazy var segmentControl = UISegmentedControl(
        items: TodoItem.Priority.allCases.map { $0.title }
    ).nt.configure {
        $0.addTarget(
            self,
            action: #selector(segmentDidChanged),
            for: .valueChanged
        )
    }
    
    func bind(viewModel: PriorityViewModel) {
        _ = viewModel.transform(
            input: PriorityViewModel.Input(
                segmentControlChangeEvent: segmentControlChangeEvent
            )
        )
    }
    
    override func configureLayout() {
        [segmentControl].forEach { view.addSubview($0) }
        
        let safeArea = view.safeAreaLayoutGuide
        
        segmentControl.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeArea).inset(20)
        }
    }
    
    @objc private func segmentDidChanged() {
        segmentControlChangeEvent.onNext(segmentControl.selectedSegmentIndex)
    }
}
