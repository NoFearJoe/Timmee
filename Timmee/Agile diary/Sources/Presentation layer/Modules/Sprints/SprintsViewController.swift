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

final class SprintsViewController: BaseViewController, AlertInput {
    
    @IBOutlet private var sprintsView: UICollectionView!
    
    @IBOutlet private var placeholderContainer: UIView!
    private lazy var placeholderView = PlaceholderView.loadedFromNib()
    
    private let sprintsService = ServicesAssembly.shared.sprintsService
    private let sprintsObserver = ServicesAssembly.shared.sprintsService.sprintsObserver()
    private var sprintsCacheAdapter: CollectionViewCacheAdapter!
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare() {
        super.prepare()
        title = "my_sprints".localized
        sprintsCacheAdapter = CollectionViewCacheAdapter(collectionView: sprintsView)
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
        setupPlaceholderAppearance()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let chartsViewController = (segue.destination as? UINavigationController)?.topViewController as? ChartsViewController {
            chartsViewController.sprint = sender as? Sprint
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func setupSprintsObserver() {
        sprintsObserver.setActions(onInitialFetch: nil,
                                   onItemsCountChange: { [unowned self] count in
                                       count == 0 ? self.showPlaceholder() : self.hidePlaceholder()
                                   },
                                   onItemChange: nil,
                                   onBatchUpdatesStarted: nil,
                                   onBatchUpdatesCompleted: nil)
        sprintsObserver.setMapping { entity in
            let entity = entity as! SprintEntity
            return Sprint(sprintEntity: entity)
        }
        
        sprintsObserver.setSubscriber(sprintsCacheAdapter)
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
        return cell
    }
    
}

extension SprintsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let selectedSprint = sprintsObserver.item(at: indexPath)
    }
    
}

extension SprintsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sprint = sprintsObserver.item(at: indexPath)
        let width = collectionView.bounds.width - (collectionViewLayout as! UICollectionViewFlowLayout).sectionInset.left * 2
        switch sprint.tense {
        case .past:
            return CGSize(width: width, height: 156)
        case .current, .future:
            return CGSize(width: width, height: 100)
        }
    }
    
}

extension SprintsViewController: SwipableCollectionViewCellActionsProvider {
    
    func actions(forCellAt indexPath: IndexPath) -> [SwipeCollectionAction] {
        let sprint = sprintsObserver.item(at: indexPath)

        let removeSprintAction = SwipeCollectionAction(icon: UIImage(named: "trash") ?? UIImage(),
                                                       tintColor: AppTheme.current.colors.wrongElementColor)
            { [unowned self] indexPath in
                self.sprintsView.hideSwipedCell()
                self.showRemoveSprintConfirmationAlert { confirmed in
                    guard confirmed else { return }
                    self.view.isUserInteractionEnabled = false
                    self.sprintsService.removeSprint(sprint, completion: { _ in
                        self.view.isUserInteractionEnabled = true
                    })
                }
            }
        
        let showChartsAction = SwipeCollectionAction(icon: UIImage(named: "charts") ?? UIImage(),
                                                     tintColor: AppTheme.current.colors.mainElementColor)
            { [unowned self] indexPath in
                self.sprintsView.hideSwipedCell()
                self.performSegue(withIdentifier: "ShowCharts", sender: sprint)
            }
        
        switch sprint.tense {
        case .past: return [showChartsAction]
        case .current: return [showChartsAction, removeSprintAction]
        case .future: return [removeSprintAction]
        }
    }
    
    private func showRemoveSprintConfirmationAlert(completion: @escaping (Bool) -> Void) {
        showAlert(title: "attention".localized,
                  message: "are_you_sure_you_want_to_remove_sprint".localized,
                  actions: [.cancel, .ok("remove".localized)]) { action in
                      switch action {
                      case .cancel: completion(false)
                      case .ok: completion(true)
                      }
                  }
    }
    
}

private extension SprintsViewController {
    
    func setupPlaceholder() {
        placeholderView.setup(into: placeholderContainer)
        placeholderContainer.isHidden = true
    }
    
    func setupPlaceholderAppearance() {
        placeholderView.backgroundColor = .clear
        placeholderView.titleLabel.font = AppTheme.current.fonts.medium(18)
        placeholderView.subtitleLabel.font = AppTheme.current.fonts.regular(14)
        placeholderView.titleLabel.textColor = AppTheme.current.textColorForTodayLabelsOnBackground
        placeholderView.subtitleLabel.textColor = AppTheme.current.textColorForTodayLabelsOnBackground
    }
    
    func showPlaceholder() {
        placeholderContainer.isHidden = false
        placeholderView.icon = #imageLiteral(resourceName: "calendar")
        placeholderView.title = "there_is_no_sprints".localized
        placeholderView.subtitle = nil
    }
    
    func hidePlaceholder() {
        placeholderContainer.isHidden = true
    }
    
}
