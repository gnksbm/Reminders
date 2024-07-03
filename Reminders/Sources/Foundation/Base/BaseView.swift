//
//  BaseView.swift
//  Reminders
//
//  Created by gnksbm on 7/2/24.
//

import UIKit

class BaseView: UIView {
    init() {
        super.init(frame: .zero)
        configureUI()
        configureLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() { }
    func configureLayout() { }
}
