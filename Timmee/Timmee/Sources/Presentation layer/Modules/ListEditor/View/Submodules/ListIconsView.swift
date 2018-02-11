//
//  ListIconsView.swift
//  Timmee
//
//  Created by Илья Харабет on 11.02.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import class UIKit.UIImageView
import class UIKit.UICollectionView
import class UIKit.UICollectionViewCell
import class UIKit.UICollectionViewController
import struct Foundation.IndexPath
import struct CoreGraphics.CGFloat

// MARK: - Input
protocol ListIconsViewInput: class {
    weak var output: ListIconsViewOutput? { get set }
    func setListIcon(_ icon: ListIcon)
}

// MARK: - Output
protocol ListIconsViewOutput: class {
    func didSelectListIcon(_ icon: ListIcon)
    func didChangeContentHeight(_ height: CGFloat)
}

// MARK: - Class
final class ListIconsView: UICollectionViewController {
    
    weak var output: ListIconsViewOutput?
    
    private var selectedListIcon: ListIcon = .default {
        didSet {
            output?.didSelectListIcon(selectedListIcon)
        }
    }
    
    private var lastCollectionViewContentHeight: CGFloat = 0
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let collectionViewContentHeight = collectionView?.contentSize.height ?? 0
        if lastCollectionViewContentHeight != collectionViewContentHeight {
            lastCollectionViewContentHeight = collectionViewContentHeight
            output?.didChangeContentHeight(collectionViewContentHeight)
        }
    }
    
}

// MARK: - ListIconsViewInput
extension ListIconsView: ListIconsViewInput {
    
    func setListIcon(_ icon: ListIcon) {
        selectedListIcon = icon
    }
    
}

// MARK: - UICollectionViewDataSource
extension ListIconsView {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ListIcon.all.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListIconCell", for: indexPath) as! ListIconCell
        
        if let icon = ListIcon.all.item(at: indexPath.item) {
            cell.icon = icon
            cell.isSelected = icon == selectedListIcon
        }
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate
extension ListIconsView {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let icon = ListIcon.all.item(at: indexPath.item) {
            selectedListIcon = icon
            collectionView.reloadData()
        }
    }
    
}

// MARK: ListIconCell
final class ListIconCell: UICollectionViewCell {
    
    @IBOutlet fileprivate weak var iconView: UIImageView!
    
    var icon: ListIcon? {
        didSet {
            iconView.image = icon?.image
        }
    }
    
    override var isSelected: Bool {
        didSet {
            iconView.tintColor = isSelected ? AppTheme.current.blueColor : AppTheme.current.thirdlyTintColor
        }
    }
    
}
