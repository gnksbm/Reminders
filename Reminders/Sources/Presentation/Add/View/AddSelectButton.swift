//
//  AddSelectButton.swift
//  Reminders
//
//  Created by gnksbm on 7/4/24.
//

import UIKit

import SnapKit
import Neat

final class AddSelectButton: BaseView {
    private let titleLabel = UILabel().nt.configure {
        $0.font(.systemFont(ofSize: 16))
    }
    
    private let subInfoLabel = UILabel().nt.configure {
        $0.font(.systemFont(ofSize: 14))
    }
    
    private let detailDisclosureImageView = UIImageView().nt.configure {
        $0.image(UIImage(systemName: "chevron.right"))
            .tintColor(.secondaryLabel)
            .preferredSymbolConfiguration(
                UIImage.SymbolConfiguration(font: .systemFont(ofSize: 13))
            )
                 
    }
    
    private let multipleImageView = MultiImageScrollView()
    
    init(title: String, infoColor: UIColor = .label) {
        super.init()
        titleLabel.text = title
        subInfoLabel.textColor = infoColor
    }
    
    func addTarget(
        _ target: Any?,
        action: Selector
    ) {
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        addGestureRecognizer(tapGesture)
    }
    
    func updateSubInfo(text: String) {
        subInfoLabel.text = text
    }
    
    func updateImage(images: [UIImage]) {
        multipleImageView.snp.updateConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
                .offset(images.isEmpty ? 0 : 20)
            make.height.equalTo(images.isEmpty ? 0 : bounds.width * 0.25)
        }
        multipleImageView.updateView(with: images)
    }
    
    override func configureUI() {
        layer.cornerRadius = 12
        clipsToBounds = true
        backgroundColor = .secondarySystemBackground
    }
    
    override func configureLayout() {
        [
            titleLabel,
            subInfoLabel,
            detailDisclosureImageView,
            multipleImageView
        ].forEach {
            addSubview($0)
        }
        
        let inset = 20.f
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(self).inset(inset)
        }
        
        subInfoLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(inset)
            make.centerY.equalTo(titleLabel)
            make.trailing.equalTo(detailDisclosureImageView.snp.leading)
                .offset(-inset)
        }
        
        detailDisclosureImageView.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalTo(self).inset(inset)
        }
        
        multipleImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.horizontalEdges.equalTo(self)
            make.height.equalTo(0)
            make.bottom.equalTo(self.snp.bottom).inset(inset)
        }
    }
}
