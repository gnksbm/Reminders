//
//  TodoTVHeaderView.swift
//  Reminders
//
//  Created by gnksbm on 7/3/24.
//

import UIKit

import SnapKit

final class TodoTVHeaderView: BaseView {
    private let titleLabel = UILabel().build { builder in
        builder.font(.boldSystemFont(ofSize: 40))
            .textColor(.tintColor)
    }
    
    func configureView(title: String) {
        titleLabel.text = title
    }
    
    override func configureLayout() {
        [titleLabel].forEach { addSubview($0) }
        
        titleLabel.snp.makeConstraints { make in
            make.edges.equalTo(self).inset(20)
        }
    }
}
