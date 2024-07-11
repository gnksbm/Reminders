//
//  FolderViewModel.swift
//  Reminders
//
//  Created by gnksbm on 7/11/24.
//

import Foundation

final class FolderViewModel: ViewModel {
    private let folderRepository = FolderRepository.shared
    
    func transform(input: Input) -> Output {
        let output = Output(
            folderList: Observable<[Folder]>([]),
            startAddFlow: Observable<Void>(()),
            updateFailure: Observable<Void>(()), 
            startFolderFlow: Observable<Folder?>(nil)
        )
        
        input.viewDidLoadEvent.bind { [weak self] _ in
            guard let self else { return }
            let folderList = self.folderRepository.fetchFolders()
            output.folderList.onNext(folderList)
        }
        
        input.plusButtonTapEvent.bind { _ in
            output.startAddFlow.onNext(())
        }
        
        input.addFolderButtonTapEvent.bind { [weak self] name in
            guard let self else { return }
            guard let name else {
                output.updateFailure.onNext(())
                return
            }
            do {
                try folderRepository.addNewFolder(folder: Folder(name: name))
                let folderList = self.folderRepository.fetchFolders()
                output.folderList.onNext(folderList)
            } catch {
                output.updateFailure.onNext(())
            }
        }
        
        input.folderSelectEvent.bind { folder in
            output.startFolderFlow.onNext(folder)
        }
        
        return output
    }
    
    struct Input {
        let viewDidLoadEvent: Observable<Void>
        let plusButtonTapEvent: Observable<Void>
        let addFolderButtonTapEvent: Observable<String?>
        let folderSelectEvent: Observable<Folder?>
    }
    
    struct Output {
        let folderList: Observable<[Folder]>
        let startAddFlow: Observable<Void>
        let updateFailure: Observable<Void>
        let startFolderFlow: Observable<Folder?>
    }
}
