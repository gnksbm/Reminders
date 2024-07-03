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
    private var hashTagStr: String?
    private var priority = TodoItem.Priority.none
    
    private let textViewPlaceholder = NSAttributedString(
        string: "메모(선택)",
        attributes: [
            .foregroundColor : UIColor.tertiaryLabel,
            .font: UIFont.systemFont(ofSize: 16)
        ]
    )
    
    private let textBackgroundView = UIView().nt.configure {
        $0.backgroundColor(.secondarySystemBackground)
            .layer.cornerRadius(12)
    }
    
    private let dividerView = UIView().nt.configure { 
        $0.backgroundColor(.tertiarySystemBackground)
    }
    
    private let titleTextField = UITextField().nt.configure { 
        $0.placeholder("제목")
    }
    
    private lazy var memoTextView = UITextView().nt.configure { 
        $0.backgroundColor(.clear)
            .delegate(self)
            .attributedText(textViewPlaceholder)
    }
    
    private lazy var deadlineButton = UIButton().nt.configure { 
        $0.configuration(.rounded(title: "마감일"))
            .addTarget(
                self,
                action: #selector(deadlineButtonTapped),
                for: .touchUpInside
            )
            .perform { base in
                let longGesture = UILongPressGestureRecognizer(
                    target: self,
                    action: #selector(deadlineButtonLongPressed)
                )
                base.addGestureRecognizer(longGesture)
            }
    }
    
    private lazy var hashTagButton = UIButton().nt.configure { 
        $0.configuration(.rounded(title: "태그"))
            .addTarget(
                self,
                action: #selector(hashTagButtonTapped),
                for: .touchUpInside
            )
    }
    
    private lazy var priorityButton = UIButton().nt.configure {
        $0.configuration(.rounded(title: "우선순위"))
            .addTarget(
                self,
                action: #selector(priorityButtonTapped),
                for: .touchUpInside
            )
            .menu(makePriorityMenu())
    }
    
    private let addImageButton = UIButton().nt.configure { 
        $0.configuration(.rounded(title: "이미지 추가"))
    }
    
    deinit {
        removeObserver()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
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
                      let memoText = memoTextView.text else {
                    Logger.error(ViewComponentError.textIsNil)
                    return
                }
                guard title.isNotEmpty else {
                    showToast(message: "제목을 입력해주세요")
                    titleTextField.becomeFirstResponder()
                    return
                }
                let memo = memoText.isNotEmpty ?
                memoText != textViewPlaceholder.string ? memoText : nil :
                nil
                do {
                    var hashTag: HashTag?
                    if let hashTagStr {
                        hashTag = RealmStorage.shared.read(HashTag.self)
                            .first { $0.name == hashTagStr } ??
                        HashTag(name: hashTagStr)
                    }
                    try RealmStorage.shared.create(
                        TodoItem(
                            title: title,
                            memo: memo,
                            deadline: selectedDate,
                            hashTag: hashTag,
                            priority: priority
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
    
    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deadlineChanged),
            name: .deadline,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hashTagChanged),
            name: .hashTag,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(priorityChanged),
            name: .priority,
            object: nil
        )
    }
    
    private func removeObserver() {
        NSNotification.Name.all.forEach {
            NotificationCenter.default.removeObserver(
                self,
                name: $0,
                object: nil
            )
        }
    }
    
    private func showDateModal() {
        let alertVC = UIAlertController(
            title: "마감일을 선택해주세요",
            message: nil,
            preferredStyle: .actionSheet
        )
        let datePicker = UIDatePicker().nt.configure {
            $0.preferredDatePickerStyle(.inline)
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
    
    private func makePriorityMenu() -> UIMenu {
        UIMenu(
            title: "",
            children: TodoItem.Priority.allCases.map { priority in
                var image: UIImage?
                if self.priority == priority {
                    image = UIImage(systemName: "checkmark")
                }
                return UIAction(
                    title: priority.title,
                    image: image
                ) { _ in
                    self.priority = priority
                }
            }
        )
        
    }
    
    @objc private func deadlineButtonTapped() {
        navigationController?.pushViewController(
            DateViewController(selectedDate: selectedDate),
            animated: true
        )
    }
    
    @objc private func deadlineButtonLongPressed() {
        showDateModal()
    }
    
    @objc private func hashTagButtonTapped() {
        navigationController?.pushViewController(
            TagViewController(hashTag: hashTagStr),
            animated: true
        )
    }
    
    @objc private func priorityButtonTapped() {
        navigationController?.pushViewController(
            PriorityViewController(index: priority.rawValue),
            animated: true
        )
    }
    
    @objc private func deadlineChanged(_ notification: NSNotification) { 
        guard let date = notification.userInfo?["date"] as? Date else {
            Logger.debug("""
                Date 변환 실패
                Value: \(String(describing: notification.userInfo?["date"]))
            """)
            return
        }
        selectedDate = date
    }
    
    @objc private func hashTagChanged(_ notification: NSNotification) {
        guard let hashTag = notification.userInfo?["hashTag"] as? String else {
            Logger.debug("""
                String 변환 실패
                Value: \(String(describing: notification.userInfo?["date"]))
            """)
            return
        }
        hashTagStr = hashTag
    }
    
    @objc private func priorityChanged(_ notification: NSNotification) {
        guard let priorityIndex =
                notification.userInfo?["priorityIndex"] as? Int else {
            Logger.debug("""
                Int 변환 실패
                Value: \(String(describing: notification.userInfo?["date"]))
            """)
            return
        }
        priority = TodoItem.Priority.allCases[priorityIndex]
        priorityButton.menu = makePriorityMenu()
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
