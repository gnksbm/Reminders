//
//  TodoListViewController.swift
//  Reminders
//
//  Created by gnksbm on 7/3/24.
//

import UIKit

final class TodoListViewController: BaseViewController {
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
        let savedItems: [TodoItem] = RealmStorage.shared.read(TodoItem.self)
            .map { $0 }
        updateSnapshot(items: savedItems)
    }
    
    override func configureLayout() {
        [tableView].forEach { view.addSubview($0) }
        
        let safeArea = view.safeAreaLayoutGuide
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(safeArea)
        }
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
}
