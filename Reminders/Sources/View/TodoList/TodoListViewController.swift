//
//  TodoListViewController.swift
//  Reminders
//
//  Created by gnksbm on 7/3/24.
//

import UIKit

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
    
    private func removeItem(indexPath: IndexPath) {
        let item = dataSource.snapshot().itemIdentifiers[indexPath.row]
        try? todoRepository.removeTodo(item: item)
        fetchItems()
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
        let removeAction = UIContextualAction(
            style: .normal,
            title: nil
        ) { [weak self] action, view, handler in
            self?.removeItem(indexPath: indexPath)
        }
        removeAction.image = UIImage(systemName: "trash")
        removeAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [removeAction])
    }
}
