//
//  SprintsViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 08.02.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import TasksKit
import UIComponents

final class SprintsViewController: BaseViewController, AlertInput, HintViewTrait {
    
    @IBOutlet private var sprintsView: UICollectionView!
    
    @IBOutlet private var createSprintButton: UIButton!
    
    @IBOutlet private var placeholderContainer: UIView!
    private lazy var placeholderView = ScreenPlaceholderView()
    
    private var selectedHintButton: UIButton?
    var hintPopover: HintPopoverView? {
        didSet {
            hintPopover?.roundedView.backgroundColor = AppTheme.current.colors.backgroundColor
            hintPopover?.textLabel?.textColor = AppTheme.current.colors.activeElementColor
            hintPopover?.triangleView.tintColor = AppTheme.current.colors.backgroundColor
            hintPopover?.willCloseBlock = {
                self.selectedHintButton?.isSelected = false
                self.selectedHintButton?.isUserInteractionEnabled = false
            }
            hintPopover?.didCloseBlock = { self.selectedHintButton?.isUserInteractionEnabled = true }
        }
    }
    
    private let sprintsService = ServicesAssembly.shared.sprintsService
    private let sprintsObserver = ServicesAssembly.shared.sprintsService.sprintsObserver()
    private var sprintsCacheAdapter: CollectionViewCacheAdapter!
    
    @IBAction func createNewSprint() {
        showNewSprintCreation(sprint: nil)
    }
    
    override func prepare() {
        super.prepare()
        
        title = "my_sprints".localized
        
        extendedLayoutIncludesOpaqueBars = true
        
        sprintsCacheAdapter = CollectionViewCacheAdapter(collectionView: sprintsView)
        
        sprintsView.contentInset.bottom = 20 + 64 + 8
        sprintsView.register(UINib(nibName: "SprintCell", bundle: nil), forCellWithReuseIdentifier: "SprintCell")
        
        setupPlaceholder()
        setupSprintsObserver()
    }
    
    override func refresh() {
        super.refresh()
        
        sprintsObserver.fetchInitialEntities()
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        
        setupCreateSprintButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let chartsViewController = (segue.destination as? UINavigationController)?.topViewController as? HabitsChartViewController {
            chartsViewController.sprint = sender as? Sprint
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        self.updateHintPopover()
    }
    
    private func setupSprintsObserver() {
        sprintsObserver.setActions(
            onInitialFetch: nil,
            onItemsCountChange: { [unowned self] count in
                count == 0 ? self.showPlaceholder() : self.hidePlaceholder()
            },
            onItemChange: nil,
            onBatchUpdatesStarted: nil,
            onBatchUpdatesCompleted: nil
        )
        
        sprintsObserver.setMapping { entity in
            let entity = entity as! SprintEntity
            return Sprint(sprintEntity: entity)
        }
        
        sprintsObserver.setSubscriber(sprintsCacheAdapter)
    }
    
    private func showNewSprintCreation(sprint: Sprint?) {
        let screen = SprintCreationViewController(sprint: sprint)
        let navigation = UINavigationController(rootViewController: screen)
        navigation.isNavigationBarHidden = true
        present(navigation, animated: true, completion: nil)
    }
    
}

extension SprintsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sprintsObserver.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sprintsObserver.numberOfItems(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SprintCell", for: indexPath) as! SprintCell
        cell.actionsProvider = self
        let sprint = sprintsObserver.item(at: indexPath)
        cell.configure(sprint: sprint)
        cell.onTapToAlert = { [unowned self] button in
            button.isSelected = !button.isSelected
            if button.isSelected {
                self.selectedHintButton = button
                self.showFullWidthHintPopover("not_ready_sprint_hint".localized, button: button)
            } else {
                self.selectedHintButton = nil
                self.hideHintPopover()
            }
        }
        return cell
    }
    
}

extension SprintsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedSprint = sprintsObserver.item(at: indexPath)
        
        if selectedSprint.tense == .future {
            showNewSprintCreation(sprint: selectedSprint)
        } else if selectedSprint.tense == .current {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideHintPopover()
    }
    
}

extension SprintsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sprint = sprintsObserver.item(at: indexPath)
        let width = collectionView.bounds.width - (collectionViewLayout as! UICollectionViewFlowLayout).sectionInset.left * 2
        switch sprint.tense {
        case .past:
            return CGSize(width: width, height: 156)
        case .current:
            return CGSize(width: width, height: 100)
        case .future:
            return CGSize(width: width, height: 66)
        }
    }
    
}

extension SprintsViewController: SwipableCollectionViewCellActionsProvider {
    
    func actions(forCellAt indexPath: IndexPath) -> [SwipeCollectionAction] {
        let sprint = sprintsObserver.item(at: indexPath)

        let removeSprintAction = SwipeCollectionAction(
            icon: UIImage(named: "trash") ?? UIImage(),
            tintColor: AppTheme.current.colors.wrongElementColor
        ) { [unowned self] indexPath in
            self.sprintsView.hideSwipedCell()
            self.showRemoveSprintConfirmationAlert { confirmed in
                guard confirmed else { return }
                self.view.isUserInteractionEnabled = false
                self.sprintsService.removeSprint(sprint, completion: { _ in
                    self.view.isUserInteractionEnabled = true
                    SprintSchedulerService().removeSprintNotifications(sprint: sprint, completion: {})
                })
            }
        }
        
        let progressSprintAction = SwipeCollectionAction(
            icon: UIImage(named: "charts") ?? UIImage(),
            tintColor: AppTheme.current.colors.mainElementColor
        ) { [unowned self] indexPath in
            self.sprintsView.hideSwipedCell()
            self.performSegue(withIdentifier: "ShowCharts", sender: sprint)
        }
        
        switch sprint.tense {
        case .past: return [progressSprintAction]
        case .current: return [progressSprintAction, removeSprintAction]
        case .future: return [removeSprintAction]
        }
    }
    
    private func showRemoveSprintConfirmationAlert(completion: @escaping (Bool) -> Void) {
        showAlert(
            title: "attention".localized,
            message: "are_you_sure_you_want_to_remove_sprint".localized,
            actions: [.cancel, .ok("remove".localized)]
        ) { action in
            switch action {
            case .cancel: completion(false)
            case .ok: completion(true)
            }
        }
    }
    
}

private extension SprintsViewController {
    
    func setupCreateSprintButton() {
        createSprintButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        createSprintButton.setTitleColor(.white, for: .normal)
        createSprintButton.tintColor = .white
    }
    
    func setupPlaceholder() {
        placeholderView.setup(into: placeholderContainer)
        placeholderContainer.isHidden = true
        placeholderContainer.backgroundColor = AppTheme.current.colors.middlegroundColor
    }
    
    func showPlaceholder() {
        placeholderContainer.isHidden = false
        placeholderView.configure(
            title: "there_is_no_sprints".localized,
            message: nil,
            action: "create_sprint".localized
        ) { [unowned self] in
            self.present(SprintCreationViewController(sprint: nil, canBeClosed: true), animated: true, completion: nil)
        }
    }
    
    func hidePlaceholder() {
        placeholderContainer.isHidden = true
    }
    
}
