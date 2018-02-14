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
    func resetState()
}

protocol ListsViewOutput: class {
    func didSelectList(_ list: List)
    func didPickList(_ list: List)
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
    @IBOutlet private var addListMenuButton: UIButton!
    @IBOutlet private var addSmartListMenuButton: UIButton!
    @IBOutlet private var dimmedBackgroundView: BarView!
    
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
        
        dimmedBackgroundView.isHidden = true
        addListMenu.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dimmedBackgroundView.backgroundColor = AppTheme.current.foregroundColor.withAlphaComponent(0.75)
        
        addListMenu.arrangedSubviews.forEach { view in
            guard let button = view as? UIButton else { return }
            button.backgroundColor = AppTheme.current.blueColor
            button.setBackgroundImage(UIImage.plain(color: AppTheme.current.blueColor), for: .normal)
            button.setBackgroundImage(UIImage.plain(color: AppTheme.current.blueColor.withAlphaComponent(0.9)), for: .highlighted)
            button.tintColor = AppTheme.current.backgroundTintColor
        }
        
        addListButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.blueColor), for: .normal)
        addListButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.thirdlyTintColor), for: UIControlState.selected)
        addListButton.tintColor = AppTheme.current.backgroundTintColor
        
        addListMenuButton.setTitle("list".localized, for: .normal)
        addSmartListMenuButton.setTitle("smart_list".localized, for: .normal)
    }
    
    @IBAction private func didSelectAddListMenuItem() {
        output?.didAskToAddList()
        hideAddListMenu(animated: true)
    }
    
    @IBAction private func didSelectAddSmartListMenuItem() {
        output?.didAskToAddSmartList()
        hideAddListMenu(animated: true)
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
    
    func resetState() {
        collectionView.hideSwipedCell()
        hideAddListMenu()
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
        func reloadPreviousCell(for indexPath: IndexPath) {
            guard indexPath.item > 0 else { return }
            collectionView.reloadItems(at: [IndexPath(item: indexPath.item - 1, section: indexPath.section)])
        }
        
        func reloadNextCell(for indexPath: IndexPath) {
            guard collectionView.numberOfItems(inSection: indexPath.section) > indexPath.item else { return }
            collectionView.reloadItems(at: [IndexPath(item: indexPath.item, section: indexPath.section)])
        }
        
        switch change {
        case .insertion(let indexPath):
            if ListsCollectionViewSection(rawValue: indexPath.section) == .lists {
                currentList = listsInteractor.list(at: indexPath.row, in: indexPath.section)
            }
            
            collectionView.performBatchUpdates({
                reloadPreviousCell(for: indexPath)
                reloadNextCell(for: indexPath)
            })
        case .deletion(let indexPath):
            if currentListIndexPath == nil || indexPath == currentListIndexPath {
                currentList = listsInteractor.list(at: 0, in: ListsCollectionViewSection.smartLists.rawValue)
            }
            
            collectionView.performBatchUpdates({
                reloadPreviousCell(for: indexPath)
                reloadNextCell(for: indexPath)
            })
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
        addListMenu.transform = makeAddListMenuInitialTransform()
        
        addListMenu.isHidden = false
        dimmedBackgroundView.isHidden = false
        UIView.animate(withDuration: animated ? 0.2 : 0) {
            self.addListMenu.alpha = 1
            self.dimmedBackgroundView.alpha = 1
            self.addListMenu.transform = .identity
            self.addListButton.isSelected = true
            self.addListButton.transform = self.makeAddListButtonRotationTransform()
        }
    }
    
    func hideAddListMenu(animated: Bool = false) {
        UIView.animate(withDuration: animated ? 0.2 : 0,
                       animations: {
            self.addListMenu.alpha = 0
            self.dimmedBackgroundView.alpha = 0
            self.addListMenu.transform = self.makeAddListMenuInitialTransform()
            self.addListButton.isSelected = false
            self.addListButton.transform = .identity
        }) { _ in
            self.addListMenu.isHidden = true
            self.dimmedBackgroundView.isHidden = true
        }
    }
    
    func makeAddListMenuInitialTransform() -> CGAffineTransform {
        let translation = CGAffineTransform(translationX: 0, y: 64)
        let scale = CGAffineTransform(scaleX: 0.1, y: 0.1)
        return scale.concatenating(translation)
    }
    
    func makeAddListButtonRotationTransform() -> CGAffineTransform {
        return CGAffineTransform(rotationAngle: 45 * .pi / 180)
    }
    
}
