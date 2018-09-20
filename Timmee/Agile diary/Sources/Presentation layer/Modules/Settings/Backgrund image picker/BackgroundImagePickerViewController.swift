//
//  BackgroundImagePickerViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 20.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class BackgroundImagePickerViewController: BaseViewController {
    
    @IBOutlet private var collectionView: UICollectionView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "pick_background_image".localized
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.title = "pick_background_image".localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
}

extension BackgroundImagePickerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BackgroundImage.all.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BackgroundImagePickerCell", for: indexPath) as! BackgroundImagePickerCell
        let image = BackgroundImage.all[indexPath.item]
        cell.configure(image: image.image, isPicked: image == BackgroundImage.current)
        return cell
    }
    
}

extension BackgroundImagePickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = BackgroundImage.all[indexPath.item]
        guard image != BackgroundImage.current else { return }
        let currentImageIndexPath = IndexPath(item: BackgroundImage.all.index(of: BackgroundImage.current) ?? 0, section: 0)
        UserProperty.backgroundImage.setString(image.rawValue)
        collectionView.reloadItems(at: [currentImageIndexPath, indexPath])
    }
    
}

extension BackgroundImagePickerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
}

final class BackgroundImagePickerCell: UICollectionViewCell {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var checkbox: Checkbox!
    
    func configure(image: UIImage, isPicked: Bool) {
        imageView.image = image
        checkbox.isChecked = isPicked
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        checkbox.isChecked = false
    }
    
}
