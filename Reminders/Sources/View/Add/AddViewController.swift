//
//  AddViewController.swift
//  Reminders
//
//  Created by gnksbm on 7/2/24.
//

import UIKit

import SnapKit

final class AddViewController: BaseViewController {
    private var selectedDate: Date?
    
    private let textViewPlaceholder = NSAttributedString(
        string: "메모(선택)",
        attributes: [
            .foregroundColor : UIColor.tertiaryLabel,
            .font: UIFont.systemFont(ofSize: 16)
        ]
    )
    
    private let textBackgroundView = UIView().build { builder in
        builder.backgroundColor(.secondarySystemBackground)
            .layer.cornerRadius(12)
    }
    
    private let dividerView = UIView().build { builder in
        builder.backgroundColor(.tertiarySystemBackground)
    }
    
    private let titleTextField = UITextField().build { builder in
        builder.placeholder("제목")
    }
    
    private lazy var memoTextView = UITextView().build { builder in
        builder.backgroundColor(.clear)
            .delegate(self)
            .attributedText(textViewPlaceholder)
    }
    
    private lazy var deadlineButton = UIButton().build { builder in
        builder.configuration(.rounded(title: "마감일"))
            .addTarget(
                self,
                action: #selector(deadlineButtonTapped),
                for: .touchUpInside
            )
    }
    
    private let hashTagButton = UIButton().build { builder in
        builder.configuration(.rounded(title: "태그"))
    }
    
    private let priorityButton = UIButton().build { builder in
        builder.configuration(.rounded(title: "우선순위"))
    }
    
    private let addImageButton = UIButton().build { builder in
        builder.configuration(.rounded(title: "이미지 추가"))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        [
            deadlineButton,
            hashTagButton,
            priorityButton,
            addImageButton
        ].forEach { button in
            guard let titleWidth = button.titleLabel?.bounds.width,
                  let imageWidth = button.imageView?.bounds.width,
                  let contentInsets = button.configuration?.contentInsets
            else { return }
            button.configuration?.imagePadding =
            button.bounds.width -
            imageWidth -
            contentInsets.leading -
            contentInsets.trailing -
            titleWidth
        }
    }
    
    override func configureNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "취소",
            primaryAction: UIAction { [weak self] _ in
                self?.dismiss(animated: true)
            }
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "추가",
            primaryAction: UIAction {
                [weak self] _ in
                guard let self else { return }
                guard let title = titleTextField.text,
                      let memo = memoTextView.text else {
                    Logger.error(ViewComponentError.textIsNil)
                    return
                }
                guard title.isNotEmpty else {
                    showToast(message: "제목을 입력해주세요")
                    titleTextField.becomeFirstResponder()
                    return
                }
                guard selectedDate != nil else {
                    showToast(message: "마감일을 선택해주세요")
                    return
                }
                do {
                    try RealmStorage.shared.create(
                        TodoItem(
                            title: title,
                            memo: memo.isNotEmpty ? memo : nil,
                            priority: .none
                        )
                    )
                    dismiss(animated: true)
                } catch {
                    Logger.error(error)
                }
            }
        )
    }
    
    override func configureLayout() {
        [
            textBackgroundView,
            dividerView,
            titleTextField,
            memoTextView,
            deadlineButton,
            hashTagButton,
            priorityButton,
            addImageButton
        ].forEach { view.addSubview($0) }
        
        let safeArea = view.safeAreaLayoutGuide
        
        let inset = 20.f
        
        textBackgroundView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeArea).inset(inset)
            make.height.equalTo(textBackgroundView.snp.width).multipliedBy(0.5)
        }
        
        titleTextField.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(textBackgroundView).inset(inset)
        }
        
        dividerView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(inset)
            make.horizontalEdges.equalTo(titleTextField)
            make.height.equalTo(1)
        }
        
        memoTextView.snp.makeConstraints { make in
            make.top.equalTo(dividerView.snp.bottom)
            make.horizontalEdges.bottom.equalTo(textBackgroundView)
                .inset(inset * 0.75)
        }
        
        deadlineButton.snp.makeConstraints { make in
            make.top.equalTo(textBackgroundView.snp.bottom).offset(inset)
            make.horizontalEdges.equalTo(textBackgroundView)
        }
        
        hashTagButton.snp.makeConstraints { make in
            make.top.equalTo(deadlineButton.snp.bottom).offset(inset)
            make.horizontalEdges.equalTo(textBackgroundView)
        }
        
        priorityButton.snp.makeConstraints { make in
            make.top.equalTo(hashTagButton.snp.bottom).offset(inset)
            make.horizontalEdges.equalTo(textBackgroundView)
        }
        
        addImageButton.snp.makeConstraints { make in
            make.top.equalTo(priorityButton.snp.bottom).offset(inset)
            make.horizontalEdges.equalTo(textBackgroundView)
        }
    }
    
    override func configureNavigationTitle() {
        navigationItem.title = "새로운 할 일"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .black)
        ]
    }
    
    @objc private func deadlineButtonTapped() {
        let alertVC = UIAlertController(
            title: "마감일을 선택해주세요",
            message: nil,
            preferredStyle: .actionSheet
        )
        let datePicker = UIDatePicker().build { builder in
            builder.preferredDatePickerStyle(.inline)
        }
        if let selectedDate {
            datePicker.date = selectedDate
        }
        alertVC.addAction(
            UIAlertAction(title: "설정하기", style: .default) { [weak self] _ in
                guard let self else { return }
                selectedDate = datePicker.date
            }
        )
        alertVC.addAction(
            UIAlertAction(title: "취소", style: .cancel)
        )
        let contentViewController = UIViewController()
        contentViewController.view = datePicker
        alertVC.setValue(contentViewController, forKey: "contentViewController")
        present(alertVC, animated: true)
    }
}

extension AddViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.attributedText == textViewPlaceholder {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.attributedText = textViewPlaceholder
        }
    }
}
