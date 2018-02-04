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
    
    @IBOutlet private var addListButton: UIButton!
    @IBOutlet private var addListMenu: UIStackView!
    
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
            addListButton.isHidden = isPickingList
            if collectionView.numberOfSections >= 1 {
                collectionView.reloadSections(IndexSet(integer: ListsCollectionViewSection.smartLists.rawValue))
            }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addListButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.blueColor), for: .normal)
        addListButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.blueColor.withAlphaComponent(0.8)), for: .highlighted)
        addListButton.tintColor = AppTheme.current.backgroundTintColor
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
        collectionView.hideSwipedCell()
    }
    
}

extension ListsViewController: ListsInteractorOutput {
    
    func prepareListsObserver(_ collectionViewManageble: CollectionViewManageble) {
        collectionViewManageble.setCollectionView(collectionView)
    }
    
    func didFetchInitialLists() {
        if currentList == nil {
            currentList = listsInteractor.list(at: 0, in: ListsCollectionViewSection.smartLists.rawValue)
        }
    }
    
    func didUpdateLists(with change: CoreDataItemChange) {
        switch change {
        case .insertion(let indexPath):
            currentList = listsInteractor.list(at: indexPath.row, in: indexPath.section)
        case .deletion(let indexPath):
            if currentListIndexPath == nil || indexPath == currentListIndexPath {
                currentList = listsInteractor.list(at: 0, in: ListsCollectionViewSection.smartLists.rawValue)
            }
            
            if indexPath.item > 0 {
                collectionView.reloadItems(at: [IndexPath(item: indexPath.item - 1, section: indexPath.section)])
            }
            if collectionView.numberOfItems(inSection: indexPath.section) > indexPath.item {
                collectionView.reloadItems(at: [IndexPath(item: indexPath.item, section: indexPath.section)])
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
            currentList = listsInteractor.list(at: 0, in: ListsCollectionViewSection.smartLists.rawValue)
        }
    }
    
    func didUpdateSmartLists(with change: CoreDataItemChange) {
        didUpdateLists(with: change)
    }
    
}

private extension ListsViewController {
    
    @IBAction func toggleAddListMenu() {
        if addListMenu.isHidden {
            showAddListMenu(animated: true)
        } else {
            hideAddListMenu(animated: true)
        }
    }
    
    func showAddListMenu(animated: Bool = false) {
        addListMenu.isHidden = false
        UIView.animate(withDuration: animated ? 0.1 : 0) {
            self.addListMenu.alpha = 1
        }
    }
    
    func hideAddListMenu(animated: Bool = false) {
        UIView.animate(withDuration: animated ? 0.1 : 0,
                       animations: {
            self.addListMenu.alpha = 0
        }) { _ in
            self.addListMenu.isHidden = true
        }
    }
    
}
