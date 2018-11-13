//
//  ShopCategoriesViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 13.11.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class ShopCategoriesViewController: BaseViewController {
    
    @IBOutlet private var collectionView: UICollectionView!
    
    override func prepare() {
        super.prepare()
    }
    
    override func refresh() {
        super.refresh()
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        collectionView.backgroundColor = AppTheme.current.colors.middlegroundColor
    }
    
}

extension ShopCategoriesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShopCategoryCell", for: indexPath) as! ShopCategoryCell
        cell.configure(title: "a", backgroundImage: UIImage())
        return cell
    }
    
}

extension ShopCategoriesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}

extension ShopCategoriesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .zero
    }
    
}

final class ShopCategoryCell: UICollectionViewCell {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var backgroundImageView: UIImageView!
    
    func configure(title: String, backgroundImage: UIImage) {
        titleLabel.text = title
        backgroundImageView.image = backgroundImage
    }
    
}
