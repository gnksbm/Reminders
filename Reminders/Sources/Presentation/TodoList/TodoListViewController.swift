//
//  TodoListViewController.swift
//  Reminders
//
//  Created by gnksbm on 7/3/24.
//

import UIKit
import Neat

final class TodoListViewController: BaseViewController {
    private var todoRepository = TodoRepository.shared
    
    private var filter: (TodoItem) -> Bool
    private var dataSource: DataSource!
    
    private lazy var tableView = UITableView().nt.configure { 
        $0.register(TodoListTVCell.self)
            .delegate(self)
    }
    
    init(filter: @escaping (TodoItem) -> Bool) {
        self.filter = filter
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchItems()
    }
    
    override func configureNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            menu: UIMenu(children: [
                UIAction(title: "마감일 순으로 보기") { [weak self] _ in
                    guard let self else { return }
                    fetchItems()
                    let sortedItems = dataSource.snapshot().itemIdentifiers
                        .sorted { lhs, rhs in
                            guard let lhs = lhs.deadline,
                                  let rhs = rhs.deadline else { return false }
                            return lhs < rhs
                    }
                    updateSnapshot(items: sortedItems)
                },
                UIAction(title: "제목 순으로 보기") { [weak self] _ in
                    guard let self else { return }
                    fetchItems()
                    let sortedItems = dataSource.snapshot().itemIdentifiers
                        .sorted { lhs, rhs in
                            return lhs.title < rhs.title
                    }
                    updateSnapshot(items: sortedItems)
                },
                UIAction(title: "우선순위 낮음 만 보기") { [weak self] _ in
                    guard let self else { return }
                    fetchItems()
                    let filteredItems = dataSource.snapshot().itemIdentifiers
                        .filter { $0.priority == .low }
                    updateSnapshot(items: filteredItems)
                }
            ])
        )
    }
    
    override func configureLayout() {
        [tableView].forEach { view.addSubview($0) }
        
        let safeArea = view.safeAreaLayoutGuide
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(safeArea)
        }
    }
    
    private func fetchItems() {
        let savedItems: [TodoItem] = 
        Array(RealmStorage.shared.read(TodoItem.self).filter(filter))
        updateSnapshot(items: savedItems)
    }
    
    private func starItem(item: TodoItem) throws { }
    
    private func flagItem(item: TodoItem) throws {
        try todoRepository.update(item: item) {
            $0.isFlag.toggle()
        }
        NotificationCenter.default.post(
            name: .todoChanged,
            object: nil
        )
        fetchItems()
    }
    
    private func removeItem(item: TodoItem) throws {
        try todoRepository.removeTodo(item: item)
        fetchItems()
    }
    
    private func makeContextualAction(
        image: UIImage?,
        color: UIColor,
        indexPath: IndexPath,
        completion: @escaping () throws -> Void
    ) -> UIContextualAction {
        let removeAction = UIContextualAction(
            style: .normal,
            title: nil
        ) { [weak self] action, view, handler in
            do {
                try completion()
            } catch {
                self?.showToast(message: "잠시후 다시 시도해주세요")
                Logger.error(error)
            }
            handler(true)
        }
        removeAction.image = image
        removeAction.backgroundColor = color
        return removeAction
    }
    
    private func reloadTableView() {
        dataSource.applySnapshotUsingReloadData(dataSource.snapshot())
    }
}

extension TodoListViewController {
    private func configureDataSource() {
        dataSource = DataSource(
            tableView: tableView,
            cellProvider: { tableView, indexPath, item in
                tableView.dequeueReusableCell(
                    cellType: TodoListTVCell.self,
                    for: indexPath
                ).nt.configure {
                    $0.checkButtonHandler(
                        { [weak self] in
                            guard let self else { return }
                            do {
                                try todoRepository.update(item: item) {
                                    $0.isDone.toggle()
                                }
                                NotificationCenter.default.post(
                                    name: .todoChanged,
                                    object: nil
                                )
                                reloadTableView()
                            } catch {
                                showToast(message: "잠시후 다시 시도해주세요")
                                Logger.error(error)
                            }
                        }
                    )
                    .perform { base in
                        base.configureCell(item: item)
                    }
                }
            }
        )
    }
    
    private func updateSnapshot(items: [TodoItem]) {
        var snapshot = Snapshot()
        let allSection = TableViewSection.allCases
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
    
    enum TableViewSection: CaseIterable {
        case all
        
        var title: String {
            switch self {
            case .all:
                "전체"
            }
        }
    }
    
    typealias DataSource =
    UITableViewDiffableDataSource<TableViewSection, TodoItem>
    
    typealias Snapshot =
    NSDiffableDataSourceSnapshot<TableViewSection, TodoItem>
}



extension TodoListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        TodoTVHeaderView().nt.configure { 
            $0.perform { base in
                base.configureView(
                    title: TableViewSection.allCases[section].title
                )
            }
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let item = dataSource.snapshot().itemIdentifiers[indexPath.row]
        navigationController?.pushViewController(
            TodoDetailViewController(item: item),
            animated: true
        )
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let item = dataSource.snapshot().itemIdentifiers[indexPath.row]
        let starAction = makeContextualAction(
            image: UIImage(systemName: "star"),
            color: .secondaryLabel,
            indexPath: indexPath
        ) { [weak self] in
            try self?.starItem(item: item)
        }
        let flagAction = makeContextualAction(
            image: UIImage(systemName: "flag"),
            color: .orange,
            indexPath: indexPath
        ) { [weak self] in
            try self?.flagItem(item: item)
        }
        let removeAction = makeContextualAction(
            image: UIImage(systemName: "trash"),
            color: .red,
            indexPath: indexPath
        ) { [weak self] in
            try self?.removeItem(item: item)
        }
        
        return UISwipeActionsConfiguration(
            actions: [
                removeAction,
                flagAction,
                starAction
            ]
        )
    }
}
