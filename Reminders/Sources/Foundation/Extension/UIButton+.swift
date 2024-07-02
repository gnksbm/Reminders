//
//  UIButton+.swift
//  Reminders
//
//  Created by gnksbm on 7/2/24.
//

import UIKit

extension UIButton.Configuration {
    static func rounded(title: String) -> Self {
        var config = Self.bordered()
        config.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer([
                .font: UIFont.systemFont(ofSize: 16)
            ])
        )
        config.baseForegroundColor = .label
        config.baseBackgroundColor = .secondarySystemBackground
        config.image = UIImage(systemName: "chevron.right")
        config.imagePlacement = .trailing
        config.preferredSymbolConfigurationForImage =
        UIImage.SymbolConfiguration(font: .systemFont(ofSize: 13))
        config.cornerStyle = .large
        config.contentInsets = .same(equal: 20.f)
        return config
    }
}
