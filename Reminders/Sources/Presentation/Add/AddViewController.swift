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
    private let viewModel = AddViewModel()
    
    private let titleInputEvent = Observable<String?>(nil)
    private let memoInputEvent = Observable<String?>(nil)
    private let saveButtonTapEvent = Observable<Void>(())
    private let cancelButtonTapEvent = Observable<Void>(())
    private let navigationButtonTapEvent =
    Observable<NavigationEventType?>(nil)
    
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
    
    private lazy var navigationButtons = NavigationEventType.allCases
        .map { eventType in
            AddSelectButton(
                title: eventType.title
            ).nt.configure {
                $0.tag(eventType.rawValue)
                    .perform { base in
                        base.addTarget(
                            self,
                            action: #selector(navigationButtonTapped)
                        )
                    }
            }
        }
    
    private lazy var buttonStackView = UIStackView(
        arrangedSubviews: navigationButtons
    ).nt.configure {
        $0.axis(.vertical)
            .spacing(20)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    override func configureNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "취소",
            primaryAction: UIAction { [weak self] _ in
                self?.cancelButtonTapEvent.onNext(())
            }
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "추가",
            primaryAction: UIAction { [weak self] _ in
                self?.saveButtonTapEvent.onNext(())
            }
        )
    }
    
    override func configureLayout() {
        [
            textBackgroundView,
            dividerView,
            titleTextField,
            memoTextView,
            buttonStackView
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
        
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(textBackgroundView.snp.bottom).offset(inset)
            make.horizontalEdges.equalTo(textBackgroundView)
        }
    }
    
    override func configureNavigationTitle() {
        navigationItem.title = "새로운 할 일"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .black)
        ]
    }
    
    private func bind() {
        let output = viewModel.transform(
            input: AddViewModel.Input(
                titleInputEvent: titleInputEvent,
                memoInputEvent: memoInputEvent,
                saveButtonTapEvent: saveButtonTapEvent,
                cancelButtonTapEvent: cancelButtonTapEvent,
                navigationButtonTapEvent: navigationButtonTapEvent
            )
        )
        
        output.deadline.bind { [weak self] date in
            if let date {
                self?.navigationButtons.first(
                    where: { $0.tag == NavigationEventType.deadline.rawValue }
                )?.updateSubInfo(
                    text: date.formatted(dateFormat: .todoOutput)
                )
            }
        }
        
        output.hashTag.bind { [weak self] hashTag in
            if let hashTag {
                self?.navigationButtons.first(
                    where: { $0.tag == NavigationEventType.hashTag.rawValue }
                )?.updateSubInfo(text: "#\(hashTag)")
            }
        }
        
        output.priority.bind { [weak self] priority in
            self?.navigationButtons.first(
                where: { $0.tag == NavigationEventType.priority.rawValue }
            )?.updateSubInfo(text: priority.title)
        }
        
        output.images.bind { [weak self] selectedImage in
            let addImageButton = self?.navigationButtons.first(
                where: { $0.tag == NavigationEventType.image.rawValue }
            )
            addImageButton?.updateSubInfo(
                text: "선택된 이미지 \(selectedImage.count)개"
            )
            addImageButton?.updateImage(images: selectedImage)
        }
        
        output.imageDidSelected.bind { [weak self] in
            self?.dismiss(animated: true)
        }
        
        output.folder.bind { [weak self] folder in
            if let folder {
                self?.navigationButtons.first(
                    where: { $0.tag == NavigationEventType.folder.rawValue }
                )?.updateSubInfo(text: "경로: \(folder.name)")
            }
        }
        
        output.errorMessage.bind { [weak self] message in
            self?.showToast(message: message)
        }
        
        output.flowFinished.bind { [weak self] _ in
            self?.dismiss(animated: true)
        }
        
        output.startFlow.bind { [weak self] eventType in
            guard let self,
                  let eventType else { return }
            switch eventType {
            case .deadline:
                navigationController?.pushViewController(
                    DeadlineViewController(vmDelegate: viewModel),
                    animated: true
                )
            case .hashTag:
                navigationController?.pushViewController(
                    TagViewController(vmDelegate: viewModel),
                    animated: true
                )
            case .priority:
                navigationController?.pushViewController(
                    PriorityViewController(vmDelegate: viewModel),
                    animated: true
                )
            case .image:
                var config = PHPickerConfiguration()
                config.selectionLimit = 0
                let phPicker = PHPickerViewController(configuration: config)
                phPicker.delegate = viewModel
                present(phPicker, animated: true)
            case .folder:
                navigationController?.pushViewController(
                    FolderViewController(
                        viewType: .browse(
                            action: { [weak self] folder in
                                self?.viewModel.folderSelected(folder: folder)
                            }
                        )
                    ), 
                    animated: true
                )
            }
        }
    }
    
    @objc private func navigationButtonTapped(
        _ sender: UITapGestureRecognizer
    ) {
        guard let tag = sender.view?.tag else { return }
        navigationButtonTapEvent.onNext(
            NavigationEventType.allCases[tag]
        )
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
