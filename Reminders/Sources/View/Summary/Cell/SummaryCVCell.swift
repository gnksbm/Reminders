//
//  SummaryCVCell.swift
//  Reminders
//
//  Created by gnksbm on 7/3/24.
//

import UIKit

final class SummaryCVCell: BaseCollectionViewCell {
    private let iconImageView = UIImageView().build { builder in
        builder.contentMode(.scaleAspectFill)
            .backgroundColor(.label)
            .clipsToBounds(true)
            .preferredSymbolConfiguration(
                UIImage.SymbolConfiguration(font: .systemFont(ofSize: 28))
            )
    }
    
    private let titleLabel = UILabel().build { builder in
        builder.textColor(.secondaryLabel)
            .font(.systemFont(ofSize: 17, weight: .semibold))
    }
    
    private let countLabel = UILabel().build { builder in
        builder.textColor(.label)
            .font(.boldSystemFont(ofSize: 28))
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        iconImageView.layer.cornerRadius = iconImageView.bounds.width / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }
    
    func configureCell(item: SummaryViewController.CollectionViewItem) {
        iconImageView.image = item.icon?
            .resizableImage(withCapInsets: .same(equal: -2))
        iconImageView.tintColor = item.iconColor
        titleLabel.text = item.title
        countLabel.text = item.getItemCount().formatted()
    }
    
    override func configureUI() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 15
        clipsToBounds = true
    }
    
    override func configureLayout() {
        [
            iconImageView,
            titleLabel,
            countLabel
        ].forEach { contentView.addSubview($0) }
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(10)
            make.leading.equalTo(contentView).inset(15)
        }
        
        countLabel.snp.makeConstraints { make in
            make.centerY.equalTo(iconImageView)
            make.leading.greaterThanOrEqualTo(iconImageView.snp.trailing)
                .inset(15)
            make.trailing.equalTo(contentView).inset(15)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView).inset(15)
            make.bottom.equalTo(contentView).inset(10)
        }
    }
}
