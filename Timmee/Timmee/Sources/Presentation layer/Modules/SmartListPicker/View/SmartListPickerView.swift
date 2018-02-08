//
//  SmartListPickerView.swift
//  Timmee
//
//  Created by i.kharabet on 07.02.18.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class SmartListPickerView: UIViewController {
    
    var state = SmartListsPickerState()
    
    let interactor = SmartListsPickerInteractor()
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var collectionViewContainer: BarView!
    
    @IBOutlet private var doneButton: UIButton!
    
    @IBAction private func done() {
        dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitioningDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = AppTheme.current.backgroundColor
        collectionViewContainer.backgroundColor = AppTheme.current.middlegroundColor
        doneButton.tintColor = AppTheme.current.greenColor
        
        state.smartLists = interactor.obtainSmartLists()
        state.selectedSmartLists = interactor.obtainSelectedSmartLists()
        
        collectionView.reloadData()
    }
    
}

extension SmartListPickerView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return state.smartLists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SmartListPickerCell", for: indexPath) as! SmartListPickerCell
        if let list = state.smartLists.item(at: indexPath.item) {
            cell.title = list.title
            cell.icon = list.icon.image
            cell.isPicked = state.selectedSmartLists.contains(list)
            
            cell.roundedCorners = self.roundedCorners(forListAt: indexPath)
        }
        return cell
    }
    
}

extension SmartListPickerView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let list = state.smartLists.item(at: indexPath.item) else { return }
        
        let targetSelectedState = !state.selectedSmartLists.contains(list)
        
        view.isUserInteractionEnabled = false
        
        interactor.setSmartListSelected(smartList: list, isSelected: targetSelectedState) { [weak self] in
            if targetSelectedState == true {
                self?.state.selectedSmartLists.append(list)
            } else {
                self?.state.selectedSmartLists.remove(object: list)
            }
            
            DispatchQueue.main.async {
                self?.collectionView.reloadItems(at: [indexPath])
                
                self?.view.isUserInteractionEnabled = true
            }
        }
    }
    
}

extension SmartListPickerView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 16, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
    
}

extension SmartListPickerView: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalPresentationTransition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalDismissalTransition()
    }
    
}

private extension SmartListPickerView {
    
    func roundedCorners(forListAt indexPath: IndexPath) -> UIRectCorner {
        let itemsCount = state.smartLists.count
        
        switch (indexPath.item, itemsCount) {
        case (_, 0...1): return .allCorners
        case (0, _): return [.topLeft, .topRight]
        case (let index, let itemsCount) where index == itemsCount - 1: return [.bottomLeft, .bottomRight]
        default: return []
        }
    }
    
}
