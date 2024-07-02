//
//  SummaryViewController.swift
//  Reminders
//
//  Created by gnksbm on 7/2/24.
//

import UIKit

final class SummaryViewController: BaseViewController {
    override func configureNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction { [weak self] _ in
                self?.present(
                    UINavigationController(
                        rootViewController: AddViewController()
                    ),
                    animated: true
                )
            }
        )
    }
}

// MARK: UICollectionView
extension SummaryViewController {
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout {
            _,
            _ in
            let inset = 5.f
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1/2),
                    heightDimension: .fractionalWidth(1/4)
                )
            )
            item.contentInsets = .same(equal: inset)
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalWidth(1)
                ),
                subitems: [item]
            )
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .same(equal: inset)
            return section
        }
    }
    
    enum Section: CaseIterable {
        case all
        
        var title: String {
            switch self {
            case .all:
                "전체"
            }
        }
    }
}
