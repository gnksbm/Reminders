//
//  MultipleImageView.swift
//  Reminders
//
//  Created by gnksbm on 7/7/24.
//

import UIKit

import SnapKit

final class MultipleImageView: BaseView {
    var axis = NSLayoutConstraint.Axis.horizontal {
        didSet {
            stackView.axis = axis
        }
    }
    var spacing = 20.f
    
    private let scrollView = UIScrollView()
    
    private lazy var stackView = UIStackView().nt.configure {
        $0.spacing(spacing)
            .distribution(.equalSpacing)
    }
    
    func updateView(with images: [UIImage]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        images.forEach { image in
            let imageView = UIImageView().nt.configure {
                $0.image(image)
                    .contentMode(.scaleAspectFill)
                    .layer.cornerRadius(4)
                    .clipsToBounds(true)
            }
            stackView.addArrangedSubview(imageView)
            
            imageView.widthAnchor.constraint(equalTo: stackView.heightAnchor)
                .isActive = true
        }
    }
    
    override func configureLayout() {
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        scrollView.contentLayoutGuide.snp.makeConstraints { make in
            make.verticalEdges.equalTo(self)
        }
        
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(scrollView.contentLayoutGuide)
                .inset(20)
            make.verticalEdges.equalTo(scrollView.contentLayoutGuide)
        }
    }
}
