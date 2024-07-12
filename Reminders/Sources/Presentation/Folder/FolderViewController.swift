//
//  FolderViewController.swift
//  Reminders
//
//  Created by gnksbm on 7/8/24.
//

import UIKit

import SnapKit

final class FolderViewController: BaseViewController, View {
    private let viewType: ViewType
    
    private let viewDidLoadEvent = Observable<Void>(())
    private let plusButtonTapEvent = Observable<Void>(())
    private let addFolderButtonTapEvent = Observable<String?>(nil)
    private let folderSelectEvent = Observable<Folder?>(nil)
    
    private var dataSource: DataSource!
    
    private lazy var tableView = UITableView().nt.configure {
        $0.register(FolderTVCell.self)
            .delegate(self)
    }
    
    init(viewType: ViewType) {
        self.viewType = viewType
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
        viewDidLoadEvent.onNext(())
    }
    
    func bind(viewModel: FolderViewModel) {
        let output = viewModel.transform(
            input: FolderViewModel.Input(
                viewDidLoadEvent: viewDidLoadEvent,
                plusButtonTapEvent: plusButtonTapEvent,
                addFolderButtonTapEvent: addFolderButtonTapEvent,
                folderSelectEvent: folderSelectEvent
            )
        )
        
        output.folderList.bind { [weak self] folderList in
            self?.updateSnapshot(items: folderList)
        }
        
        output.startAddFlow.bind { [weak self] _ in
            let textField = UITextField().nt.configure {
                $0.borderStyle(.roundedRect)
                    .backgroundColor(.secondarySystemBackground)
            }
            self?.showActionSheet(
                title: "폴더명을 입력해주세요",
                view: textField,
                action: UIAlertAction(
                    title: "완료",
                    style: .default
                ) { _ in
                    guard let name = textField.text else {
                        Logger.nilObject(textField, keyPath: \.text)
                        return
                    }
                    self?.addFolderButtonTapEvent.onNext(name)
                }
            )
        }
        
        output.updateFailure.bind { [weak self] _ in
            self?.showToast(message: "잠시후 다시 시도해주세요")
        }
        
        output.startFolderFlow.bind { [weak self] folder in
            guard let self,
                  let folder else { return }
            switch viewType {
            case .overview:
                let todoVC = TodoListViewController()
                todoVC.viewModel = TodoListViewModel { todo in
                    todo.parentFolder == folder
                }
                navigationController?.pushViewController(
                    todoVC,
                    animated: true
                )
            case .browse(let action):
                action(folder)
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func configureNavigation() {
        let textField = UITextField().nt.configure {
            $0.borderStyle(.roundedRect)
                .backgroundColor(.secondarySystemBackground)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction { [weak self] _ in
                self?.showActionSheet(
                    title: "폴더명을 입력해주세요",
                    view: textField,
                    action: UIAlertAction(
                        title: "완료",
                        style: .default
                    ) { _ in
                        guard let name = textField.text else {
                            Logger.nilObject(textField, keyPath: \.text)
                            return
                        }
                        self?.addFolderButtonTapEvent.onNext(name)
                    }
                )
            }
        )
    }
    
    override func configureLayout() {
        [tableView].forEach { view.addSubview($0) }
        
        let safeArea = view.safeAreaLayoutGuide
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(safeArea)
        }
    }
}

extension FolderViewController {
    private func configureDataSource() {
        dataSource = DataSource(
            tableView: tableView,
            cellProvider: { tableView, indexPath, item in
                tableView.dequeueReusableCell(
                    cellType: FolderTVCell.self,
                    for: indexPath
                ).nt.configure {
                    $0.perform { base in
                        base.configureCell(item: item)
                    }
                }
            }
        )
    }
    
    private func updateSnapshot(items: [Folder]) {
        var snapshot = Snapshot()
        let allSection = TableViewSection.allCases
        snapshot.appendSections(allSection)
        allSection.forEach { section in
            switch section {
            case .main:
                snapshot.appendItems(
                    items,
                    toSection: section
                )
            }
        }
        dataSource.apply(snapshot)
    }
    
    enum TableViewSection: CaseIterable {
        case main
    }
    
    typealias DataSource =
    UITableViewDiffableDataSource<TableViewSection, Folder>
    
    typealias Snapshot =
    NSDiffableDataSourceSnapshot<TableViewSection, Folder>
}

extension FolderViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let folder = dataSource.snapshot().itemIdentifiers[indexPath.row]
        folderSelectEvent.onNext(folder)
    }
}

extension FolderViewController {
    enum ViewType {
        case overview, browse(action: (Folder) -> Void)
    }
}
