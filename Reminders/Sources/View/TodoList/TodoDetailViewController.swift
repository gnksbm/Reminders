//
//  TodoDetailViewController.swift
//  Reminders
//
//  Created by gnksbm on 7/4/24.
//

import UIKit

import SnapKit

final class TodoDetailViewController: BaseViewController {
    private let textView = UITextView()
    
    init(item: TodoItem) {
        super.init()
        let maString = NSMutableAttributedString()
        let title = NSAttributedString(
            string: item.title,
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: 20),
                .foregroundColor: UIColor.label
            ]
        )
        maString.append(title)
        let priority = NSAttributedString(
            string: " 우선순위 \(item.priority.title)\n",
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: 15),
                .foregroundColor: UIColor.label
            ]
        )
        maString.append(priority)
        if let memo = item.memo {
            let memo = NSAttributedString(
                string: "\(memo)\n",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 15),
                    .foregroundColor: UIColor.label
                ]
            )
            maString.append(memo)
        }
        if let deadline = item.deadline?.formatted(dateFormat: .todoOutput) {
            let deadline = NSAttributedString(
                string: deadline,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 13),
                    .foregroundColor: UIColor.label
                ]
            )
            maString.append(deadline)
        }
        if let hashTag = item.hashTag?.name {
            let hashTag = NSAttributedString(
                string: " #\(hashTag)",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 13),
                    .foregroundColor: UIColor.tintColor
                ]
            )
            maString.append(hashTag)
        }
        textView.attributedText = maString
    }
    
    override func configureLayout() {
        [textView].forEach { view.addSubview($0) }
        
        let safeArea = view.safeAreaLayoutGuide
        
        textView.snp.makeConstraints { make in
            make.edges.equalTo(safeArea)
        }
    }
}
