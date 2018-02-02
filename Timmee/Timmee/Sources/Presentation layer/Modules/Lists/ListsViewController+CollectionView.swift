//
//  ListsViewController+CollectionView.swift
//  Timmee
//
//  Created by i.kharabet on 31.01.18.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

private enum ListsCollectionViewSection: Int {
    case addList
    case smartLists
    case lists
    
    init(rawValue: Int) {
        switch rawValue {
        case 0: self = .addList
        case 1: self = .smartLists
        default: self = .lists
        }
    }
}

extension ListsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return listsInteractor.numberOfSections() + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if ListsCollectionViewSection(rawValue: section) == .addList {
            return isPickingList ? 0 : 2
        } else if  ListsCollectionViewSection(rawValue: section) == .smartLists, isPickingList {
            return 0
        }
        return listsInteractor.numberOfItems(in: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = ListsCollectionViewSection(rawValue: indexPath.section)
        if section == .addList {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddListCollectionViewCell", for: indexPath) as! AddListCollectionViewCell
            cell.title = indexPath.item == 0 ? "Список" : "Smart список" // TODO
            cell.icon = #imageLiteral(resourceName: "plus_thin")
            cell.roundedCorners = self.roundedCorners(forAddListCellAt: indexPath)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCollectionViewCell", for: indexPath) as! ListCollectionViewCell
            if let list = listsInteractor.list(at: indexPath.item, in: indexPath.section) {
                cell.title = list.title
                cell.icon = list.icon.image
                
                let tasksCount = listsInteractor.activeTasksCount(in: list)
                if tasksCount > 0 {
                    cell.tasksCount = "\(tasksCount)"
                } else {
                    cell.tasksCount = nil
                }
                
                cell.isPicked = currentList == list
                
                cell.roundedCorners = self.roundedCorners(forListAt: indexPath)
                
                cell.actionsProvider = self
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ListsSectionView", for: indexPath) as! ListsSectionView
            
            let section = ListsCollectionViewSection(rawValue: indexPath.section)
            if section == .smartLists {
                view.title = "Smart списки" // TODO
            } else if section == .lists {
                view.title = "Мои списки" // TODO
            }
            
            return view
        } else {
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "", for: indexPath)
        }
    }
    
}

extension ListsViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isPickingList, ListsCollectionViewSection(rawValue: indexPath.section) == .lists {
            if let list = listsInteractor.list(at: indexPath.row, in: indexPath.section) {
                output?.didPickList(list)
            }
        } else {
            if ListsCollectionViewSection(rawValue: indexPath.section) == .addList {
                if indexPath.item == 0 {
                    output?.didAskToAddList()
                } else {
                    output?.didAskToAddSmartList()
                }
            } else {
                currentList = listsInteractor.list(at: indexPath.row, in: indexPath.section)
                collectionView.reloadData()
                output?.didSelectList(currentList)
            }
        }
    }
    
}

extension ListsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if ListsCollectionViewSection(rawValue: indexPath.section) == .addList {
            return CGSize(width: (collectionView.frame.width - 16) * 0.5, height: 44)
        } else {
            if UIDevice.current.isIpad {
                let itemsCount = listsInteractor.numberOfItems(in: indexPath.section)
                
                let width: CGFloat
                
                if indexPath.item == itemsCount - 1 && indexPath.item % 2 == 0 {
                    width = collectionView.frame.width - 16
                } else {
                    width = (collectionView.frame.width - 16) * 0.5
                }
                
                return CGSize(width: width, height: 44)
            } else {
                return CGSize(width: collectionView.frame.width - 16, height: 44)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if ListsCollectionViewSection(rawValue: section) == .addList {
            return .zero
        } else if ListsCollectionViewSection(rawValue: section) == .smartLists, isPickingList {
            return .zero
        } else if listsInteractor.numberOfItems(in: section) == 0 {
            return .zero
        }
        return CGSize(width: collectionView.frame.width, height: 32)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
    
}

extension ListsViewController: SwipableCollectionViewCellActionsProvider {
    
    func actions(forCellAt indexPath: IndexPath) -> [SwipeCollectionAction] {
        if indexPath.section == 1 {
            let hideAction = SwipeCollectionAction(icon: #imageLiteral(resourceName: "trash"), // TODO
                                                   tintColor: AppTheme.current.secondaryTintColor,
                                                   action: handleSmartListHidding)
            return [hideAction]
        } else if indexPath.section == 2 {
            let deleteAction = SwipeCollectionAction(icon: #imageLiteral(resourceName: "trash"),
                                                     tintColor: AppTheme.current.redColor,
                                                     action: handleListDeletion)
            let editAction = SwipeCollectionAction(icon: #imageLiteral(resourceName: "edit_thin"),
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
        if let list = listsInteractor.list(at: indexPath.row, in: indexPath.section) as? SmartList {
            listsInteractor.hideSmartList(list)
        }
    }
    
    func handleListDeletion(at indexPath: IndexPath) {
        if let list = listsInteractor.list(at: indexPath.row, in: indexPath.section) {
            if listsInteractor.tasksCount(in: list) > 0 {
                showListDeletionAlert(with: list)
            } else {
                listsInteractor.removeList(list)
            }
        }
    }
    
    func handleListEditing(at indexPath: IndexPath) {
        if let list = listsInteractor.list(at: indexPath.row, in: indexPath.section) {
            self.output?.didAskToEditList(list)
        }
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

private extension ListsViewController {
    
    func roundedCorners(forListAt indexPath: IndexPath) -> UIRectCorner {
        let itemsCount = listsInteractor.numberOfItems(in: indexPath.section)
        
        if UIDevice.current.isIpad {
            switch (indexPath.item, itemsCount) {
            case (_, 0...1): return .allCorners
            case (0, _): return [.topLeft]
            case (1, _): return [.topRight]
            case (let index, let itemsCount) where index == itemsCount - 1:
                if index % 2 == 0 {
                    return [.bottomLeft, .bottomRight]
                } else {
                    return .bottomRight
                }
            default: return []
            }
        } else {
            switch (indexPath.item, itemsCount) {
            case (_, 0...1): return .allCorners
            case (0, _): return [.topLeft, .topRight]
            case (let index, let itemsCount) where index == itemsCount - 1: return [.bottomLeft, .bottomRight]
            default: return []
            }
        }
    }
    
    func roundedCorners(forAddListCellAt indexPath: IndexPath) -> UIRectCorner {
        if indexPath.item == 0 {
            return [.topLeft, .bottomLeft]
        } else {
            return [.topRight, .bottomRight]
        }
    }
    
}
