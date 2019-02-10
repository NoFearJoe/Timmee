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

// TOOD: Placeholder
final class SprintsViewController: BaseViewController, AlertInput {
    
    @IBOutlet private var sprintsView: UICollectionView!
    
    private let sprintsService = ServicesAssembly.shared.sprintsService
    
    private var sprints: [Sprint] = []
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare() {
        super.prepare()
        title = "my_sprints".localized
        sprintsView.register(UINib(nibName: "SprintCell", bundle: nil), forCellWithReuseIdentifier: "SprintCell")
    }
    
    override func refresh() {
        super.refresh()
        reloadSprints()
    }
    
    override func setupAppearance() {
        super.setupAppearance()
    }
    
    private func reloadSprints() {
        sprints = sprintsService.fetchSprints()
        sprintsView.reloadData()
    }
    
}

extension SprintsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sprints.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SprintCell", for: indexPath) as! SprintCell
        cell.actionsProvider = self
        if let sprint = sprints.item(at: indexPath.item) {
            cell.configure(sprint: sprint)
        }
        return cell
    }
    
}

extension SprintsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedSprint = sprints.item(at: indexPath.item) else { return }
    }
    
}

extension SprintsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let sprint = sprints.item(at: indexPath.item) else { return .zero }
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
        guard let sprint = self.sprints.item(at: indexPath.item) else { return [] }

        let removeSprintAction = SwipeCollectionAction(icon: UIImage(named: "trash") ?? UIImage(),
                                                       tintColor: AppTheme.current.colors.wrongElementColor)
            { [unowned self] indexPath in
                self.sprintsView.hideSwipedCell()
                self.showRemoveSprintConfirmationAlert { confirmed in
                    guard confirmed else { return }
                    self.view.isUserInteractionEnabled = false
                    self.sprintsService.removeSprint(sprint, completion: { _ in
                        self.view.isUserInteractionEnabled = true
                        self.reloadSprints() // TODO: Cache observer
                    })
                }
            }
        
        let showChartsAction = SwipeCollectionAction(icon: UIImage(named: "charts") ?? UIImage(),
                                                     tintColor: AppTheme.current.colors.mainElementColor)
            { [unowned self] indexPath in
                self.sprintsView.hideSwipedCell()
                self.performSegue(withIdentifier: "ShowCharts", sender: nil)
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
