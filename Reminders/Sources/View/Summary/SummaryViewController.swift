//
//  SummaryViewController.swift
//  Reminders
//
//  Created by gnksbm on 7/2/24.
//

import UIKit

final class SummaryViewController: BaseViewController {
    private var dataSource: DataSource!
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: makeLayout()
    ).build { builder in
        builder.delegate(self)
            .register(SummaryCVCell.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSnapshot(items: CollectionViewItem.allCases)
    }
    
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
    
    override func configureLayout() {
        [collectionView].forEach { view.addSubview($0) }
        
        let safeArea = view.safeAreaLayoutGuide
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(safeArea)
        }
    }
}

// MARK: UICollectionView
extension SummaryViewController {
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout {
            _,
            _ in
            let inset = 10.f
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1/2),
                    heightDimension: .fractionalHeight(1)
                )
            )
            item.contentInsets = .same(equal: inset)
            let hGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1/4)
                ),
                subitems: [item]
            )
            let vGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalWidth(1)
                ),
                subitems: [hGroup]
            )
            let section = NSCollectionLayoutSection(group: vGroup)
            section.contentInsets = .same(equal: inset)
            return section
        }
    }
    
    private func configureDataSource() {
        let allCellRegistration = makeAllCellRegistration()
        dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
                switch CollectionViewSection.allCases[indexPath.section] {
                case .all:
                    collectionView.dequeueConfiguredReusableCell(
                        using: allCellRegistration,
                        for: indexPath,
                        item: CollectionViewItem.allCases[indexPath.row]
                    )
                }
            }
        )
    }
    
    private func updateSnapshot(items: [CollectionViewItem]) {
        var snapshot = Snapshot()
        let allSection = CollectionViewSection.allCases
        snapshot.appendSections(allSection)
        allSection.forEach { section in
            switch section {
            case .all:
                snapshot.appendItems(
                    items,
                    toSection: section
                )
            }
        }
        dataSource.apply(snapshot)
    }
    
    private func makeAllCellRegistration() -> AllCellRegistration {
        AllCellRegistration { cell, indexPath, item in
            cell.configureCell(item: item)
        }
    }
    
    enum CollectionViewSection: CaseIterable {
        case all
        
        var title: String {
            switch self {
            case .all:
                "전체"
            }
        }
    }
    
    enum CollectionViewItem: CaseIterable {
        case today, schedule, all, flag, done
        
        var title: String {
            switch self {
            case .today:
                "오늘"
            case .schedule:
                "예정"
            case .all:
                "전체"
            case .flag:
                "깃발 표시"
            case .done:
                "완료됨"
            }
        }
        
        var icon: UIImage? {
            switch self {
            case .today:
                UIImage(systemName: "calendar.circle.fill")
            case .schedule:
                UIImage(systemName: "calendar.circle.fill")
            case .all:
                UIImage(systemName: "tray.circle.fill")
            case .flag:
                UIImage(systemName: "flag.circle.fill")
            case .done:
                UIImage(systemName: "checkmark.circle.fill")
            }
        }
        
        var iconColor: UIColor {
            switch self {
            case .today:
                UIColor.tintColor
            case .schedule:
                UIColor.red
            case .all:
                UIColor.systemGray
            case .flag:
                UIColor.systemOrange
            case .done:
                UIColor.systemGray
            }
        }
        
        func getItemCount() -> Int {
            switch self {
            case .all:
                RealmStorage.shared.read(TodoItem.self).count
            default:
                0
            }
        }
    }
    
    typealias DataSource =
    UICollectionViewDiffableDataSource
    <CollectionViewSection, CollectionViewItem>
    
    typealias Snapshot =
    NSDiffableDataSourceSnapshot
    <CollectionViewSection, CollectionViewItem>
    
    typealias AllCellRegistration =
    UICollectionView.CellRegistration<SummaryCVCell, CollectionViewItem>
}

extension SummaryViewController: UICollectionViewDelegate { 
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        switch CollectionViewItem.allCases[indexPath.row] {
        case .all:
            navigationController?.pushViewController(
                TodoListViewController(),
                animated: true
            )
        default:
            break
        }
    }
}
