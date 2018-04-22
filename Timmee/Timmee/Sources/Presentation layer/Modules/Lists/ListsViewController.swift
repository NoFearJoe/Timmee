//
//  ListsViewController.swift
//  Timmee
//
//  Created by i.kharabet on 29.01.18.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

protocol ListsViewInput: class {
    func setCurrentList(_ list: List)
    func setPickingList(_ isPicking: Bool)
}

protocol ListsViewOutput: class {
    func didSelectList(_ list: List)
    func didPickList(_ list: List)
    func didUpdateList(_ list: List)
    func didCreateList()
    
    func willClose()
}

final class ListsViewController: UIViewController {
    
    weak var output: ListsViewOutput?
    
    @IBOutlet private var collectionViewContainer: BarView!
    @IBOutlet private var collectionView: UICollectionView!
    
    @IBOutlet private var addListButton: UIButton!
    @IBOutlet private var addListMenu: UIStackView!
    @IBOutlet private var addListMenuButton: UIButton!
    @IBOutlet private var addSmartListMenuButton: UIButton!
    @IBOutlet private var dimmedBackgroundView: BarView!
    
    let listsInteractor = ListsInteractor()
    let cacheAdapter = CollectionViewCacheAdapter()
    
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
            setPickingListIfPossible()
        }
    }
    
    private let initialDataConfigurator = InitialDataConfigurator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cacheAdapter.setCollectionView(collectionView)
        
        listsInteractor.output = self
        
        dimmedBackgroundView.isHidden = true
        addListMenu.isHidden = true
        
        setPickingListIfPossible()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionViewContainer.backgroundColor = AppTheme.current.middlegroundColor
        
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
        
        initialDataConfigurator.addInitialSmartLists { [unowned self] in
            self.listsInteractor.requestLists()
        }
    }
    
    @IBAction private func didSelectAddListMenuItem() {
        showListEditor(with: nil)
        hideAddListMenu(animated: true)
    }
    
    @IBAction private func didSelectAddSmartListMenuItem() {
        showSmartListsPicker()
        hideAddListMenu(animated: true)
    }
    
    @IBAction func close() {
        output?.willClose()
        close(completion: nil)
    }
    
    func close(completion: (() -> Void)?) {
        dismiss(animated: true, completion: completion)
    }
    
    func closeAll(completion: (() -> Void)?) {
        presentingViewController?.dismiss(animated: true, completion: completion)
    }
    
}

extension ListsViewController: ListsViewInput {
    
    func setCurrentList(_ list: List) {
        self.currentList = list
    }
    
    func setPickingList(_ isPicking: Bool) {
        isPickingList = isPicking
    }
    
}

extension ListsViewController: ListsInteractorOutput {
    
    func prepareListsObserver(_ cacheSubscribable: CacheSubscribable) {
        cacheSubscribable.setSubscriber(cacheAdapter)
    }
    
    func didFetchInitialLists() {
        guard currentList == nil else { return }
        setInitialList()
    }
    
    func didUpdateLists(with change: CoreDataChange) {
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
                setInitialList()
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
        default: break
        }
    }
    
    func prepareSmartListsObserver(_ cacheSubscribable: CacheSubscribable) {
        cacheSubscribable.setSubscriber(cacheAdapter)
    }
    
    func didFetchInitialSmartLists() {
        guard currentList == nil else { return }
        setInitialList()
    }
    
    func didUpdateSmartLists(with change: CoreDataChange) {
        didUpdateLists(with: change)
    }
    
}

extension ListsViewController: ListEditorOutput {
    
    func listCreated() {
        closeAll {
            self.output?.didCreateList()
        }
    }
    
}

extension ListsViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view?.isDescendant(of: collectionViewContainer) == false
    }
    
}

private extension ListsViewController {

    func resetState() {
        collectionView.hideSwipedCell()
        hideAddListMenu()
    }
    
    func setInitialList() {
        guard listsInteractor.numberOfItems(in: ListsCollectionViewSection.smartLists.rawValue) > 0 else { return }
        currentList = listsInteractor.list(at: 0, in: ListsCollectionViewSection.smartLists.rawValue)
    }
    
    func setPickingListIfPossible() {
        guard isViewLoaded else { return }
        addListButton.isHidden = isPickingList
        if collectionView.numberOfSections >= 1 {
            collectionView.reloadSections(IndexSet(integer: ListsCollectionViewSection.smartLists.rawValue))
        }
    }

}

private extension ListsViewController {
    
    @IBAction func toggleAddListMenu() {
        collectionView.hideSwipedCell()
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

extension ListsViewController {
    
    func showListEditor(with list: List?) {
        let listEditorView = ViewControllersFactory.listEditor
        listEditorView.loadViewIfNeeded()
        
        let listEditorInput = ListEditorAssembly.assembly(with: listEditorView)
        listEditorInput.output = self
        listEditorInput.setList(list)
        
        present(listEditorView, animated: true, completion: nil)
    }
    
    func showSmartListsPicker() {
        let smartListsPickerView = ViewControllersFactory.smartListsPicker
        smartListsPickerView.loadViewIfNeeded()
        
        present(smartListsPickerView, animated: true, completion: nil)
    }
    
}
