//
//  TagViewController.swift
//  Reminders
//
//  Created by gnksbm on 7/3/24.
//

import UIKit

import Neat

final class TagViewController: BaseViewController, View {
    private let textChangeEvent = Observable<String?>(nil)
    
    private lazy var textField = UITextField().nt.configure {
        $0.borderStyle(.roundedRect)
            .placeholder("해시태그를 입력해주세요")
            .backgroundColor(.secondarySystemBackground)
            .addTarget(
                self,
                action: #selector(textFieldDidChanged),
                for: .editingChanged
            )
    }
    
    func bind(viewModel: TagViewModel) {
        _ = viewModel.transform(
            input: TagViewModel.Input(
                textChangeEvent: textChangeEvent
            )
        )
    }
    
    override func configureLayout() {
        [textField].forEach { view.addSubview($0) }
        
        let safeArea = view.safeAreaLayoutGuide
        
        textField.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeArea).inset(20)
            make.height.equalTo(textField.snp.width).multipliedBy(0.15)
        }
    }
    
    @objc private func textFieldDidChanged() {
        textChangeEvent.onNext(textField.text)
    }
}
