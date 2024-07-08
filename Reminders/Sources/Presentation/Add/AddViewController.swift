//
//  AddViewController.swift
//  Reminders
//
//  Created by gnksbm on 7/2/24.
//

import UIKit
import PhotosUI

import SnapKit
import Neat

final class AddViewController: BaseViewController {
    private let folderRepository = FolderRepository.shared
    private let todoRepository = TodoRepository.shared
    
    private var selectedDate: Date?
    private var hashTagStr: String?
    private var priority = TodoItem.Priority.none
    private var selectedImage = [UIImage]()
    private var selectedFolder: Folder?
    
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
    
    private lazy var deadlineButton = AddSelectButton(
        title: "마감일"
    ).nt.configure {
        $0.perform { base in
            let longGesture = UILongPressGestureRecognizer(
                target: self,
                action: #selector(deadlineButtonLongPressed)
            )
            base.addGestureRecognizer(longGesture)
            base.addTarget(
                self,
                action: #selector(deadlineButtonTapped)
            )
        }
    }
    
    private lazy var hashTagButton = AddSelectButton(
        title: "태그",
        infoColor: .tintColor
    ).nt.configure {
        $0.perform { base in
            let longGesture = UILongPressGestureRecognizer(
                target: self,
                action: #selector(hashTagButtonLongPressed)
            )
            base.addGestureRecognizer(longGesture)
            base.addTarget(
                self,
                action: #selector(hashTagButtonTapped)
            )
        }
    }
    
    private lazy var priorityButton = AddSelectButton(
        title: "우선순위"
    ).nt.configure {
        $0.perform { base in
            let longGesture = UILongPressGestureRecognizer(
                target: self,
                action: #selector(priorityButtonLongPressed)
            )
            base.addGestureRecognizer(longGesture)
            base.addTarget(
                self,
                action: #selector(priorityButtonTapped)
            )
            base.updateSubInfo(text: priority.title)
        }
    }
    
    private lazy var addImageButton = AddSelectButton(
        title: "이미지 추가"
    ).nt.configure {
        $0.perform { base in
            base.addTarget(
                self,
                action: #selector(addImageButtonTapped)
            )
        }
    }
    
    private lazy var selectFolderButton = AddSelectButton(
        title: "저장할 폴더"
    ).nt.configure {
        $0.perform { base in
            base.addTarget(
                self,
                action: #selector(selectFolderButtonTapped)
            )
        }
    }
    
    deinit {
        removeObserver()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
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
            primaryAction: UIAction { [weak self] _ in
                self?.validateUserInput()
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
            addImageButton,
            selectFolderButton
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
        
        selectFolderButton.snp.makeConstraints { make in
            make.top.equalTo(addImageButton.snp.bottom).offset(inset)
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
        NSNotification.Name.allTodoItems.forEach {
            NotificationCenter.default.removeObserver(
                self,
                name: $0,
                object: nil
            )
        }
    }
    
    private func validateUserInput() {
        guard let title = titleTextField.text else {
            Logger.nilObject(titleTextField, keyPath: \.text)
            return
        }
        guard let memoText = memoTextView.text else {
            Logger.nilObject(memoTextView, keyPath: \.text)
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
        addNewItem(title: title, memo: memo)
    }
    
    private func addNewItem(
        title: String,
        memo: String?
    ) {
        do {
            var hashTag: HashTag?
            if let hashTagStr {
                hashTag = RealmStorage.shared.read(HashTag.self)
                    .first { $0.name == hashTagStr } ??
                HashTag(name: hashTagStr)
            }
            let todoItem = TodoItem(
                title: title,
                memo: memo,
                deadline: selectedDate,
                hashTag: hashTag,
                priority: priority
            )
            if let selectedFolder {
                try folderRepository.addTodoInFolder(
                    todoItem,
                    folder: selectedFolder
                )
            } else {
                try todoRepository.addNewTodo(
                    item: todoItem,
                    images: selectedImage
                )
            }
            dismiss(animated: true)
            NotificationCenter.default.post(
                name: .newTodoAdded,
                object: nil
            )
        } catch {
            showToast(message: "잠시후 다시 시도해주세요")
            Logger.error(error)
        }
    }
    
    private func updateDeadline(date: Date) {
        selectedDate = date
        deadlineButton.updateSubInfo(
            text: date.formatted(dateFormat: .todoOutput)
        )
    }
    
    private func updateHashTag(name: String) {
        hashTagStr = name.isNotEmpty ? name : nil
        hashTagButton.updateSubInfo(
            text: name.isNotEmpty ? "#\(name)" : ""
        )
    }
    
    private func updatePriority(index: Int) {
        priority = TodoItem.Priority.allCases[index]
        priorityButton.updateSubInfo(text: priority.title)
    }
    
    private func loadSelectedImage(results: [PHPickerResult]) {
        let group = DispatchGroup()
        selectedImage.removeAll()
        results.map(\.itemProvider)
            .filter { $0.canLoadObject(ofClass: UIImage.self) }
            .forEach {
                group.enter()
                $0.loadObject(
                    ofClass: UIImage.self
                ) { [weak self] item, error in
                    if let error {
                        Logger.error(error)
                        return
                    }
                    if let image = item as? UIImage {
                        self?.selectedImage.append(image)
                    }
                    group.leave()
                }
            }
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            addImageButton.updateSubInfo(
                text: "선택된 이미지 \(selectedImage.count)개"
            )
            addImageButton.updateImage(images: selectedImage)
        }
    }
    
    @objc private func deadlineButtonTapped() {
        navigationController?.pushViewController(
            DateViewController(selectedDate: selectedDate),
            animated: true
        )
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
    
    @objc private func addImageButtonTapped() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0
        let phPicker = PHPickerViewController(configuration: config)
        phPicker.delegate = self
        present(phPicker, animated: true)
    }
    
    @objc private func selectFolderButtonTapped() {
        let folderVC = FolderViewController(
            viewType: .browse(
                action: { [weak self] folder in
                    guard let self else { return }
                    selectedFolder = folder
                    selectFolderButton.updateSubInfo(
                        text: "경로: \(folder.name)"
                    )
                }
            )
        )
        navigationController?.pushViewController(folderVC, animated: true)
    }
    
    @objc private func deadlineButtonLongPressed() {
        let datePicker = UIDatePicker().nt.configure {
            $0.preferredDatePickerStyle(.inline)
        }
        if let selectedDate {
            datePicker.date = selectedDate
        }
        showActionSheet(
            title: "마감일을 선택해주세요",
            view: datePicker,
            action: UIAlertAction(
                title: "설정하기",
                style: .default
            ) {
                [weak self] _ in
                guard let self else { return }
                updateDeadline(date: datePicker.date)
            }
        )
    }
    
    @objc private func hashTagButtonLongPressed() {
        let textField = UITextField().nt.configure {
            $0.borderStyle(.roundedRect)
                .backgroundColor(.secondarySystemBackground)
        }
        showActionSheet(
            title: "해시태그를 입력해주세요",
            view: textField,
            action: UIAlertAction(
                title: "설정하기",
                style: .default
            ) {
                [weak self] _ in
                guard let self else { return }
                guard let name = textField.text else {
                    Logger.nilObject(textField, keyPath: \.text)
                    return
                }
                updateHashTag(name: name)
            }
        )
    }
    
    @objc private func priorityButtonLongPressed() {
        lazy var segmentControl = UISegmentedControl(
            items: TodoItem.Priority.allCases.map { $0.title }
        ).nt.configure {
            $0.selectedSegmentIndex(priority.rawValue)
        }
        showActionSheet(
            title: "우선순위를 선택해주세요",
            view: segmentControl,
            action: UIAlertAction(
                title: "설정하기",
                style: .default
            ) { [weak self] _ in
                self?.updatePriority(index: segmentControl.selectedSegmentIndex)
            }
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
        updateDeadline(date: date)
    }
    
    @objc private func hashTagChanged(_ notification: NSNotification) {
        guard let hashTag = notification.userInfo?["hashTag"] as? String else {
            Logger.debug("""
                String 변환 실패
                Value: \(String(describing: notification.userInfo?["date"]))
            """)
            return
        }
        updateHashTag(name: hashTag)
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
        updatePriority(index: priorityIndex)
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

extension AddViewController: PHPickerViewControllerDelegate {
    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {
        loadSelectedImage(results: results)
        dismiss(animated: true)
    }
}
