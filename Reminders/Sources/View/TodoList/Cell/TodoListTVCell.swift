//
//  TodoListTVCell.swift
//  Reminders
//
//  Created by gnksbm on 7/3/24.
//

import UIKit

import SnapKit

final class TodoListTVCell: BaseTableViewCell {
    private let checkButton = UIButton().nt.configure { 
        $0.configuration(.plain())
            .configuration.image(UIImage(systemName: "circle"))
            .configuration.baseForegroundColor(.secondaryLabel)
    }
    
    private let priorityLabel = UILabel().nt.configure { 
        $0.textColor(.tintColor)
    }
    
    private let titleLabel = UILabel()
    
    private let memoLabel = UILabel()
    
    private let deadlineLabel = UILabel()
    
    private let hashTagButton = UIButton()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        [
            priorityLabel,
            titleLabel,
            memoLabel,
            deadlineLabel
        ].forEach { $0.text = nil }
        hashTagButton.configuration?.title = nil
    }
    
    func configureCell(item: TodoItem) {
        priorityLabel.text = Array(
            repeating: "!",
            count: item.priority.rawValue
        ).joined()
        titleLabel.text = item.title
        memoLabel.text = item.memo
        deadlineLabel.text = item.deadline?.formatted(dateFormat: .todoOutput)
        if let hashTag = item.hashTag?.name {
            hashTagButton.configuration?.title = "#\(hashTag)"
        }
    }
    
    override func configureLayout() {
        [
            checkButton,
            priorityLabel,
            titleLabel,
            memoLabel,
            deadlineLabel,
            hashTagButton
        ].forEach { contentView.addSubview($0) }
        
        checkButton.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(10)
            make.leading.equalTo(contentView).inset(20)
        }
        
        priorityLabel.snp.makeConstraints { make in
            make.lastBaseline.equalTo(checkButton.snp.lastBaseline)
            make.leading.equalTo(checkButton.snp.trailing).offset(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(priorityLabel)
            make.leading.equalTo(priorityLabel.snp.trailing)
            make.trailing.lessThanOrEqualTo(contentView).inset(10)
        }
        
        memoLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalTo(priorityLabel)
            make.trailing.lessThanOrEqualTo(contentView).inset(10)
        }
        
        deadlineLabel.snp.makeConstraints { make in
            make.top.equalTo(memoLabel.snp.bottom).offset(10)
            make.leading.equalTo(memoLabel)
        }
        
        hashTagButton.snp.makeConstraints { make in
            make.top.equalTo(deadlineLabel)
            make.leading.equalTo(deadlineLabel.snp.trailing).offset(10)
            make.trailing.lessThanOrEqualTo(contentView).inset(10)
            make.bottom.equalTo(contentView).inset(20)
        }
    }
}
