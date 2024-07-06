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
    
    private var dataSource: DataSource!
    
    private lazy var tableView = UITableView().nt.configure { 
        $0.register(TodoListTVCell.self)
            .delegate(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchItems()
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
        Array(RealmStorage.shared.read(TodoItem.self))
        updateSnapshot(items: savedItems)
    }
    
    private func starItem(indexPath: IndexPath) throws { }
    
    private func flagItem(indexPath: IndexPath) throws { }
    
    private func removeItem(indexPath: IndexPath) throws {
        let item = dataSource.snapshot().itemIdentifiers[indexPath.row]
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
                    $0.perform { base in
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
        let starAction = makeContextualAction(
            image: UIImage(systemName: "star"),
            color: .secondaryLabel,
            indexPath: indexPath
        ) { [weak self] in
            try self?.starItem(indexPath: indexPath)
        }
        let flagAction = makeContextualAction(
            image: UIImage(systemName: "flag"),
            color: .orange,
            indexPath: indexPath
        ) { [weak self] in
            try self?.flagItem(indexPath: indexPath)
        }
        let removeAction = makeContextualAction(
            image: UIImage(systemName: "trash"),
            color: .red,
            indexPath: indexPath
        ) { [weak self] in
            try self?.removeItem(indexPath: indexPath)
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
