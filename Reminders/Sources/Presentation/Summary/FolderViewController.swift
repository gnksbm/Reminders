//
//  FolderViewController.swift
//  Reminders
//
//  Created by gnksbm on 7/8/24.
//

import UIKit

import SnapKit

final class FolderViewController: BaseViewController {
    private let folderRepository = FolderRepository.shared
    
    private var dataSource: DataSource!
    
    private lazy var tableView = UITableView().nt.configure {
        $0.register(FolderTVCell.self)
            .delegate(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFolders()
    }
    
    override func configureNavigation() {
        let textField = UITextField().nt.configure {
            $0.borderStyle(.roundedRect)
                .backgroundColor(.secondarySystemBackground)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction { [weak self] _ in
                guard let self else { return }
                showActionSheet(
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
                        self.addNewFolder(name: name)
                        self.fetchFolders()
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
    
    private func fetchFolders() {
        let folderResults = folderRepository.fetchFolders()
        updateSnapshot(items: Array(folderResults))
    }
    
    private func addNewFolder(name: String) {
        do {
            try folderRepository.addNewFolder(folder: Folder(name: name))
        } catch {
            showToast(message: "잠시후 다시 시도해주세요")
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
        let todoListVC = TodoListViewController { todo in
            todo.parentFolder.contains(folder) 
        }
        navigationController?.pushViewController(
            todoListVC,
            animated: true
        )
    }
}
