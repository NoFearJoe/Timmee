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
    
    func didClose()
}

final class ListsViewController: UIViewController {
    
    weak var output: ListsViewOutput?
    
    @IBOutlet private var collectionViewContainer: BarView!
    @IBOutlet private var collectionView: UICollectionView!
    
    @IBOutlet private var tagsView: ListsTagsView!
    @IBOutlet private var tagsViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private var addListButton: FloatingButton!
    @IBOutlet private var addListMenu: UIStackView!
    @IBOutlet private var addListMenuButton: UIButton!
    @IBOutlet private var addSmartListMenuButton: UIButton!
    @IBOutlet private var dimmedBackgroundView: BarView!
    
    private lazy var placeholder: PlaceholderView = PlaceholderView.loadedFromNib()
    
    let listsInteractor = ListsInteractor()
    let cacheAdapter = CollectionViewCacheAdapter()
    
    let dismissTransitionController = InteractiveDismissTransition()
    
    var currentList: List! {
        didSet {
            output?.didUpdateList(currentList)
            updateCurrentListIndexPath()
            if let indexPath = listsInteractor.indexPath(ofList: currentList) {
                collectionView.reloadItems(at: [indexPath])
            }
        }
    }
    var currentListIndexPath: IndexPath?
    
    private(set) var isPickingList: Bool = false {
        didSet {
            setPickingListIfPossible()
        }
    }
    
    private let initialDataConfigurator = InitialDataConfigurator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitioningDelegate = self
        dismissTransitionController.onClose = { [unowned self] in
            self.close()
        }
        
        setupPlaceholder()
        
        collectionView.contentInset.bottom = 104
        
        cacheAdapter.setCollectionView(collectionView)
        
        listsInteractor.output = self
        
        dimmedBackgroundView.isHidden = true
        addListMenu.isHidden = true
        
        setPickingListIfPossible()
        
        tagsView.onSelectTag = { [unowned self] tag in
            self.output?.didSelectList(SmartList(type: .tag(tag)))
            self.close()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionViewContainer.shadowRadius = 10
        collectionViewContainer.showShadow = true
        collectionViewContainer.backgroundColor = AppTheme.current.middlegroundColor
        
        dimmedBackgroundView.backgroundColor = AppTheme.current.foregroundColor.withAlphaComponent(0.75)
        
        addListMenu.arrangedSubviews.forEach { view in
            guard let button = view as? UIButton else { return }
            button.backgroundColor = AppTheme.current.blueColor
            button.setBackgroundImage(UIImage.plain(color: AppTheme.current.blueColor), for: .normal)
            button.setBackgroundImage(UIImage.plain(color: AppTheme.current.blueColor.withAlphaComponent(0.9)), for: .highlighted)
            button.tintColor = AppTheme.current.backgroundTintColor
        }
        
        addListMenuButton.setTitle("list".localized, for: .normal)
        addSmartListMenuButton.setTitle("smart_list".localized, for: .normal)
        
        initialDataConfigurator.addInitialSmartLists { [weak self] in
            self?.listsInteractor.requestLists()
        }
        
        reloadTags()
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
        close(completion: nil)
    }
    
    func close(completion: (() -> Void)?) {
        dismiss(animated: true, completion: {
            // Если window == nil, то экран закрыт и надо об этом сообщить
            guard self.view.window == nil else { return }
            completion?()
            self.output?.didClose()
        })
    }
    
    func closeAll(completion: (() -> Void)?) {
        presentingViewController?.dismiss(animated: true, completion: {
            guard self.view.window == nil else { return }
            completion?()
            self.output?.didClose()
        })
    }
    
}

extension ListsViewController: ListsViewInput {
    
    func setCurrentList(_ list: List) {
        currentList = list
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
        updatePlaceholder()
        updateCurrentListAndIndexPathIfNeeded()
    }
    
    func didUpdateLists(with change: CoreDataChange) {
        updatePlaceholder()
        
        switch change {
        case .insertion(let indexPath):
            if ListsCollectionViewSection(rawValue: indexPath.section) == .lists {
                currentList = listsInteractor.list(at: indexPath.item, in: indexPath.section)
            }
        case .deletion(let indexPath):
            if currentListIndexPath == nil || indexPath == currentListIndexPath {
                setInitialList()
            }
        case .update(let indexPath):
            guard indexPath == currentListIndexPath else { return }
            updateCurrentListAndIndexPathIfNeeded()
            if let list = listsInteractor.list(at: indexPath.item, in: indexPath.section) {
                output?.didUpdateList(list)
            }
        case .move(let indexPath, let newIndexPath):
            if let newCurrentListIndexPath = listsInteractor.indexPath(ofList: currentList) {
                currentListIndexPath = newCurrentListIndexPath
            }
            collectionView.reloadItems(at: [indexPath, newIndexPath])
        default: break
        }
    }
    
    func prepareSmartListsObserver(_ cacheSubscribable: CacheSubscribable) {
        cacheSubscribable.setSubscriber(cacheAdapter)
    }
    
    func didFetchInitialSmartLists() {
        updateCurrentListAndIndexPathIfNeeded()
    }
    
    func didUpdateSmartLists(with change: CoreDataChange) {
        didUpdateLists(with: change)
    }
    
    func blockerOperationBegan() {
        view.isUserInteractionEnabled = false
    }
    
    func blockerOperationCompleted() {
        view.isUserInteractionEnabled = true
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

extension ListsViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return dismissTransitionController.hasStarted ? dismissTransitionController : nil
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
    
    func updateCurrentListIndexPath() {
        if let indexPath = listsInteractor.indexPath(ofList: currentList) {
            currentListIndexPath = indexPath
        } else {
            currentListIndexPath = nil
        }
    }
    
    func updateCurrentListAndIndexPathIfNeeded() {
        if currentList == nil {
            setInitialList()
        }
        if currentListIndexPath == nil {
            updateCurrentListIndexPath()
        }
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
        dimmedBackgroundView.alpha = 0
        dimmedBackgroundView.isHidden = false
        UIView.animate(withDuration: animated ? 0.2 : 0) {
            self.addListMenu.alpha = 1
            self.dimmedBackgroundView.alpha = 1
            self.addListMenu.transform = .identity
            self.addListButton.setState(.active)
        }
    }
    
    func hideAddListMenu(animated: Bool = false) {
        UIView.animate(withDuration: animated ? 0.2 : 0,
                       animations: {
            self.addListMenu.alpha = 0
            self.dimmedBackgroundView.alpha = 0
            self.addListMenu.transform = self.makeAddListMenuInitialTransform()
            self.addListButton.setState(.default)
        }) { _ in
            self.addListMenu.isHidden = true
            self.dimmedBackgroundView.isHidden = true
        }
    }
    
    func setupPlaceholder() {
        placeholder.setup(into: collectionViewContainer)
        placeholder.isHidden = true
    }
    
    func updatePlaceholder() {
        if isPickingList, listsInteractor.numberOfItems(in: ListsCollectionViewSection.lists.rawValue) == 0 {
            showPlaceholder(withError: "no_lists_placeholder".localized)
        } else {
            hidePlaceholder()
        }
    }
    
    func showPlaceholder(withError error: String) {
        guard placeholder.isHidden else { return }
        placeholder.alpha = 0
        placeholder.icon = #imageLiteral(resourceName: "no_tasks")
        placeholder.title = error
        placeholder.subtitle = nil
        UIView.animate(withDuration: 0.2, animations: {
            self.placeholder.alpha = 1
        }, completion: { _ in
            self.placeholder.isHidden = false
        })
    }
    
    func hidePlaceholder() {
        guard !placeholder.isHidden else { return }
        placeholder.alpha = 1
        UIView.animate(withDuration: 0.2, animations: {
            self.placeholder.alpha = 0
        }, completion: { _ in
            self.placeholder.isHidden = true
        })
    }
    
    func makeAddListMenuInitialTransform() -> CGAffineTransform {
        let translation = CGAffineTransform(translationX: 0, y: 64)
        let scale = CGAffineTransform(scaleX: 0.1, y: 0.1)
        return scale.concatenating(translation)
    }
    
}

private extension ListsViewController {
    
    func reloadTags() {
        let tags = listsInteractor.fetchTags()
        
        tagsView.isHidden = tags.isEmpty
        tagsView.configure(tags: tags)
        tagsViewHeightConstraint.constant = tags.isEmpty ? 0 : 80
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
