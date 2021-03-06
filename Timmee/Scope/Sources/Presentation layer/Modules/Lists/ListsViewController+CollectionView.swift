//
//  ListsViewController+CollectionView.swift
//  Timmee
//
//  Created by i.kharabet on 31.01.18.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

enum ListsCollectionViewSection: Int {
    case smartLists
    case lists
    
    init(rawValue: Int) {
        switch rawValue {
        case 0: self = .smartLists
        default: self = .lists
        }
    }
}

extension ListsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return listsInteractor.numberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if ListsCollectionViewSection(rawValue: section) == .smartLists, isPickingList {
            return 0
        }
        return listsInteractor.numberOfItems(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCollectionViewCell", for: indexPath) as! ListCollectionViewCell
        if let list = listsInteractor.list(at: indexPath.item, in: indexPath.section) {
            cell.title = list.title
            cell.icon = list.icon.image
            
            let tasksCount = listsInteractor.activeTasksCount(in: list)
            cell.tasksCount = tasksCount > 0 ? "\(tasksCount)" : nil
            
            cell.isPicked = currentList == list
            cell.isFavorite = list.isFavorite
            cell.shouldShowFavoritePicker = !(list is SmartList)
            cell.favoritePicker.onPick = { [unowned self, unowned collectionView, unowned cell] _ in
                guard let indexPath = collectionView.indexPath(for: cell) else { return }
                self.handleListFavoriteChange(at: indexPath)
            }
                        
            cell.actionsProvider = self
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ListsSectionView", for: indexPath) as! ListsSectionView
            
            let section = ListsCollectionViewSection(rawValue: indexPath.section)
            if section == .smartLists {
                view.title = "smart_lists".localized
            } else if section == .lists {
                view.title = "my_lists".localized
            }
            
            return view
        } else {
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "", for: indexPath)
        }
    }
    
}

extension ListsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isPickingList {
            guard ListsCollectionViewSection(rawValue: indexPath.section) == .lists else { return }
            guard let list = listsInteractor.list(at: indexPath.row, in: indexPath.section) else { return }
            close {
                self.output?.didPickList(list)
            }
        } else {
            currentList = listsInteractor.list(at: indexPath.row, in: indexPath.section)
            collectionView.reloadData()
            output?.didSelectList(currentList)
            close()
        }
    }
    
}

extension ListsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.current.isIpad {
            let itemsCount = listsInteractor.numberOfItems(in: indexPath.section)
            
            let width: CGFloat
            
            if indexPath.item == itemsCount - 1 && indexPath.item % 2 == 0 {
                width = collectionView.frame.width - 16
            } else {
                width = (collectionView.frame.width - 24) * 0.5
            }
            
            return CGSize(width: width, height: 44)
        } else {
            return CGSize(width: collectionView.frame.width - 16, height: 44)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if ListsCollectionViewSection(rawValue: section) == .smartLists, isPickingList {
            return .zero
        } else if listsInteractor.numberOfItems(in: section) == 0 {
            return .zero
        }
        return CGSize(width: collectionView.frame.width, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
}

extension ListsViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissTransitionController.scrollViewWillBeginDragging(scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissTransitionController.scrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        dismissTransitionController.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        dismissTransitionController.scrollViewDidEndDecelerating(scrollView)
    }
    
}

extension ListsViewController: SwipableCollectionViewCellActionsProvider {
    
    func actions(forCellAt indexPath: IndexPath) -> [SwipeCollectionAction] {
        if indexPath.section == ListsCollectionViewSection.smartLists.rawValue && indexPath.item != 0 {
            let hideAction = SwipeCollectionAction(icon: #imageLiteral(resourceName: "eye"),
                                                   tintColor: AppTheme.current.secondaryTintColor,
                                                   action: handleSmartListHidding)
            return [hideAction]
        } else if indexPath.section >= ListsCollectionViewSection.lists.rawValue {
            let deleteAction = SwipeCollectionAction(icon: #imageLiteral(resourceName: "trash"),
                                                     tintColor: AppTheme.current.redColor,
                                                     action: handleListDeletion)
            let editAction = SwipeCollectionAction(icon: #imageLiteral(resourceName: "cogwheel"),
                                                   tintColor: AppTheme.current.blueColor,
                                                   action: handleListEditing)
            return [editAction, deleteAction]
        } else {
            return []
        }
    }
    
}

private extension ListsViewController {
    
    func handleSmartListHidding(at indexPath: IndexPath) {
        guard let list = listsInteractor.list(at: indexPath.row, in: indexPath.section) as? SmartList else { return }
        listsInteractor.hideSmartList(list)
    }
    
    func handleListDeletion(at indexPath: IndexPath) {
        guard let list = listsInteractor.list(at: indexPath.row, in: indexPath.section) else { return }
        if listsInteractor.tasksCount(in: list) > 0 {
            showListDeletionAlert(with: list)
        } else {
            listsInteractor.removeList(list)
        }
    }
    
    func handleListEditing(at indexPath: IndexPath) {
        guard let list = listsInteractor.list(at: indexPath.row, in: indexPath.section) else { return }
        showListEditor(with: list)
    }
    
    func handleListFavoriteChange(at indexPath: IndexPath) {
        guard let list = listsInteractor.list(at: indexPath.row, in: indexPath.section) else { return }
        listsInteractor.toggleFavoriteState(of: list)
    }
    
    func showListDeletionAlert(with list: List) {
        let alert = UIAlertController(title: "remove_list".localized,
                                      message: "are_you_sure_you_want_to_delete_the_list_with_all_tasks".localized,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "remove".localized, style: .destructive, handler: { [weak self] _ in
            self?.listsInteractor.removeList(list)
        }))
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
}
