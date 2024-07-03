//
//  AddSelectButton.swift
//  Reminders
//
//  Created by gnksbm on 7/4/24.
//

import UIKit

import SnapKit

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
    
    override func configureUI() {
        layer.cornerRadius = 12
        clipsToBounds = true
        backgroundColor = .secondarySystemBackground
    }
    
    override func configureLayout() {
        [titleLabel, subInfoLabel, detailDisclosureImageView].forEach {
            addSubview($0)
        }
        
        let inset = 20.f
        titleLabel.snp.makeConstraints { make in
            make.verticalEdges.leading.equalTo(self).inset(inset)
        }
        
        subInfoLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(inset)
            make.centerY.equalTo(self)
            make.trailing.equalTo(detailDisclosureImageView.snp.leading)
                .offset(-inset)
        }
        
        detailDisclosureImageView.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.trailing.equalTo(self).inset(inset)
        }
    }
}
