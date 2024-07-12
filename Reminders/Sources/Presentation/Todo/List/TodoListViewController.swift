//
//  TodoListViewController.swift
//  Reminders
//
//  Created by gnksbm on 7/3/24.
//

import UIKit

import Neat

final class TodoListViewController: BaseViewController, View {
    private var dataSource: DataSource!
    
    private let viewDidLoadEvent = Observable<Void>(())
    private let sortButtonTapEvent = Observable<TodoSortOption?>(nil)
    private let itemSelectEvent = Observable<TodoItem?>(nil)
    private let doneButtonTapEvent = Observable<TodoItem?>(nil)
    private let starButtonTapEvent = Observable<TodoItem?>(nil)
    private let flagButtonTapEvent = Observable<TodoItem?>(nil)
    private let removeButtonTapEvent = Observable<TodoItem?>(nil)
    
    private lazy var tableView = UITableView().nt.configure { 
        $0.register(TodoListTVCell.self)
            .delegate(self)
    }
    
    func bind(viewModel: TodoListViewModel) {
        let output = viewModel.transform(
            input: TodoListViewModel.Input(
                viewDidLoadEvent: viewDidLoadEvent,
                sortButtonTapEvent: sortButtonTapEvent,
                itemSelectEvent: itemSelectEvent,
                doneButtonTapEvent: doneButtonTapEvent,
                starButtonTapEvent: starButtonTapEvent,
                flagButtonTapEvent: flagButtonTapEvent,
                removeButtonTapEvent: removeButtonTapEvent
            )
        )
        
        output.todoList.bind { [weak self] todoList in
            self?.updateSnapshot(items: todoList)
        }
        
        output.startDetailFlow.bind { [weak self] item in
            if let item {
                let detailVC = TodoDetailViewController()
                detailVC.viewModel = TodoDetailViewModel(item: item)
                self?.navigationController?.pushViewController(
                    detailVC,
                    animated: true
                )
            }
        }
        
        output.updateSuccess.bind { [weak self] _ in
            guard let self else { return }
            dataSource.applySnapshotUsingReloadData(dataSource.snapshot())
        }
        
        output.updateFailure.bind { [weak self] error in
            guard let self,
                  let error else { return }
            showToast(message: error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
        viewDidLoadEvent.onNext(())
    }
    
    override func configureNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis.circle"),
            menu: UIMenu(
                children: TodoSortOption.allCases.map { option in
                    UIAction(title: option.title) { [weak self] _ in
                        self?.sortButtonTapEvent.onNext(option)
                    }
                }
            )
        )
    }
    
    override func configureLayout() {
        [tableView].forEach { view.addSubview($0) }
        
        let safeArea = view.safeAreaLayoutGuide
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(safeArea)
        }
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
                            self?.doneButtonTapEvent.onNext(item)
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
        itemSelectEvent.onNext(item)
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
            self?.starButtonTapEvent.onNext(item)
        }
        let flagAction = makeContextualAction(
            image: UIImage(systemName: "flag"),
            color: .orange,
            indexPath: indexPath
        ) { [weak self] in
            self?.flagButtonTapEvent.onNext(item)
        }
        let removeAction = makeContextualAction(
            image: UIImage(systemName: "trash"),
            color: .red,
            indexPath: indexPath
        ) { [weak self] in
            self?.removeButtonTapEvent.onNext(item)
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
