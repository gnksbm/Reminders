//
//  SummaryViewController.swift
//  Reminders
//
//  Created by gnksbm on 7/2/24.
//

import UIKit

import Neat

final class SummaryViewController: BaseViewController {
    private var dataSource: DataSource!
    
    private var todoItems = [TodoItem]()
    
    private lazy var addTodoButton = UIButton().nt.configure {
        $0.configuration(.plain())
            .configuration.title("새로운 할 일")
            .configuration.image(UIImage(systemName: "plus.circle.fill"))
            .configuration.imagePlacement(.leading)
            .configuration.imagePadding(10)
            .configuration.preferredSymbolConfigurationForImage(
                UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 20))
            )
            .addTarget(
                self,
                action: #selector(addTodoButtonTapped),
                for: .touchUpInside
            )
    }
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: makeLayout()
    ).nt.configure {
        $0.delegate(self)
            .register(SummaryCVCell.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        todoItems = TodoRepository.shared.fetchItems()
        configureDataSource()
        updateSnapshot(items: CollectionViewItem.allCases)
        addObserver()
    }
    
    deinit {
        removeObserver()
    }
    
    override func configureLayout() {
        [collectionView, addTodoButton].forEach { view.addSubview($0) }
        
        let safeArea = view.safeAreaLayoutGuide
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(safeArea)
        }
        
        addTodoButton.snp.makeConstraints { make in
            make.leading.bottom.equalTo(safeArea).inset(10)
        }
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(newTodoAdded),
            name: .newTodoAdded,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(todoChanged),
            name: .todoChanged,
            object: nil
        )
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: .newTodoAdded,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: .todoChanged,
            object: nil
        )
    }
    
    @objc private func addTodoButtonTapped() {
        present(
            UINavigationController(
                rootViewController: AddViewController()
            ),
            animated: true
        )
    }
    
    @objc private func newTodoAdded() {
        todoItems = TodoRepository.shared.fetchItems()
        dataSource.applySnapshotUsingReloadData(dataSource.snapshot())
    }
    
    @objc private func todoChanged(_ notification: Notification) {
        dataSource.applySnapshotUsingReloadData(dataSource.snapshot())
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
        AllCellRegistration { [weak self] cell, indexPath, item in
            guard let self else { return }
            let filter = CollectionViewItem.allCases[indexPath.row].filter
            let count = todoItems.filter(filter).count
            cell.configureCell(item: item, count: count)
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
        
        var filter: (TodoItem) -> Bool {
            switch self {
            case .today:
                { item in
                    guard let deadline = item.deadline else { return false }
                    return deadline.isToday
                }
            case .schedule:
                { item in
                    guard let deadline = item.deadline else { return false }
                    return !deadline.isToday && deadline.distance(to: .now) < 0
                }
            case .all:
                { _ in true }
            case .flag:
                { $0.isFlag }
            case .done:
                { $0.isDone }
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
        let filter = CollectionViewItem.allCases[indexPath.row].filter
        navigationController?.pushViewController(
            TodoListViewController(filter: filter),
            animated: true
        )
    }
}
