//
//  FolderTVCell.swift
//  Reminders
//
//  Created by gnksbm on 7/8/24.
//

import UIKit

final class FolderTVCell: BaseTableViewCell {
    private let nameLabel = UILabel()
    private let itemCountLabel = UILabel()
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configureCell(item: Folder) { 
        nameLabel.text = item.name
        itemCountLabel.text = item.items.count.formatted() + "개의 할 일"
    }
    
    override func configureLayout() {
        [nameLabel, itemCountLabel].forEach { contentView.addSubview($0) }
        
        nameLabel.snp.makeConstraints { make in
            make.verticalEdges.leading.equalTo(contentView).inset(20)
        }
        
        itemCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel)
            make.leading.equalTo(nameLabel.snp.trailing).offset(20)
            make.trailing.equalTo(contentView).inset(20)
        }
    }
}
