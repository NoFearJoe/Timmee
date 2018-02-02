//
//  ListsViewController.swift
//  Timmee
//
//  Created by i.kharabet on 29.01.18.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

protocol ListsViewInput: class {
    func reloadLists()
    func setPickingList(_ isPicking: Bool)
    func resetRevealedCells()
}

protocol ListsViewOutput: class {
    func didSelectList(_ list: List)
    func didPickList(_ list: List) // TODO: Refactor?
    func didUpdateList(_ list: List)
    func didAskToAddList()
    func didAskToAddSmartList()
    func didAskToEditList(_ list: List)
}

final class ListsViewController: UIViewController {
    
    weak var output: ListsViewOutput?
    
    @IBOutlet private var collectionView: UICollectionView!
    
    let listsInteractor = ListsInteractor()
    
    var currentList: List! {
        didSet {
            output?.didUpdateList(currentList)
            if let indexPath = listsInteractor.indexPath(ofList: currentList) {
                collectionView.reloadItems(at: [indexPath])
            }
        }
    }
    var currentListIndexPath: IndexPath? {
        guard let list = currentList else { return nil }
        return listsInteractor.indexPath(ofList: list)
    }
    
    private(set) var isPickingList: Bool = false {
        didSet {
            collectionView.reloadSections(IndexSet(integersIn: 0...1))
        }
    }
    
    let initialDataConfigurator = InitialDataConfigurator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listsInteractor.output = self
        
        initialDataConfigurator.addInitialSmartLists { [unowned self] in
            self.listsInteractor.requestLists()
        }
    }
    
}

extension ListsViewController: ListsViewInput {
    
    func reloadLists() {
        listsInteractor.requestLists()
        collectionView.setContentOffset(.zero, animated: false)
    }
    
    func setPickingList(_ isPicking: Bool) {
        isPickingList = isPicking
    }
    
    func resetRevealedCells() {
        // TODO
    }
    
}

extension ListsViewController: ListsInteractorOutput {
    
    func prepareListsObserver(_ collectionViewManageble: CollectionViewManageble) {
        collectionViewManageble.setCollectionView(collectionView)
    }
    
    func didFetchInitialLists() {
        if currentList == nil {
            currentList = listsInteractor.list(at: 0, in: 1)
        }
    }
    
    func didUpdateLists(with change: CoreDataItemChange) {
        switch change {
        case .insertion(let indexPath):
            currentList = listsInteractor.list(at: indexPath.row, in: indexPath.section)
        case .deletion(let indexPath):
            if currentListIndexPath == nil || indexPath == currentListIndexPath {
                currentList = listsInteractor.list(at: 0, in: 1)
            }
        case .update(let indexPath):
            guard indexPath == currentListIndexPath else { return }
            if let list = listsInteractor.list(at: indexPath.row, in: indexPath.section) {
                output?.didUpdateList(list)
            }
        case .move(let indexPath, let newIndexPath):
            if indexPath == currentListIndexPath {
                currentList = listsInteractor.list(at: newIndexPath.row, in: newIndexPath.section)
            }
        }
    }
    
    func prepareSmartListsObserver(_ collectionViewManageble: CollectionViewManageble) {
        collectionViewManageble.setCollectionView(collectionView)
    }
    
    func didFetchInitialSmartLists() {
        if currentList == nil {
            currentList = listsInteractor.list(at: 0, in: 1)
        }
    }
    
    func didUpdateSmartLists(with change: CoreDataItemChange) {
        didUpdateLists(with: change)
    }
    
}

final class ListsSectionView: UICollectionReusableView {
    
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = AppTheme.current.secondaryTintColor
        }
    }
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue?.uppercased() }
    }
    
}
