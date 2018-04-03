//
//  PhotoPreviewViewController.swift
//  Timmee
//
//  Created by i.kharabet on 20.12.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class PhotoPreviewViewController: UIViewController {
    
    @IBOutlet fileprivate var photosCollectionView: PhotoPreviewCollectionView!
    @IBOutlet fileprivate var photosCountLabel: UILabel!
    @IBOutlet fileprivate var closeButton: UIButton!
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    var photos: [UIImage] = [] {
        didSet {
            photosCollectionView.reloadData()
        }
    }
    
    var startPosition: Int = 0 {
        didSet {
            photosCollectionView.scrollToPhoto(at: startPosition, animated: false)
            updatePhotosCount()
        }
    }
    
    fileprivate var isInterfaceHidden = false
    
    override var prefersStatusBarHidden: Bool {
        return isInterfaceHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTapGestureRecognizer()
        
        closeButton.tintColor = AppTheme.current.backgroundTintColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePhotosCount()
    }
    
}

extension PhotoPreviewViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoPreviewCollectionCell", for: indexPath) as! PhotoPreviewCollectionCell
        
        cell.photo = photos.item(at: indexPath.item)
        
        return cell
    }
    
}

extension PhotoPreviewViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
}

extension PhotoPreviewViewController {
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updatePhotosCount()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePhotosCount()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        updatePhotosCount()
    }
    
}

fileprivate extension PhotoPreviewViewController {
    
    func addTapGestureRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        view.addGestureRecognizer(recognizer)
    }
    
    @objc func onTap() {
        isInterfaceHidden = !isInterfaceHidden
        updateInterfaceVisibility()
    }
    
    func updateInterfaceVisibility() {
        setNeedsStatusBarAppearanceUpdate()
        
        closeButton.isHidden = isInterfaceHidden
        updatePhotosCount()
    }
    
    func updatePhotosCount() {
        photosCountLabel.isHidden = photos.count <= 1 || isInterfaceHidden
        photosCountLabel.text = "\(photosCollectionView.currentIndex + 1) \("of".localized) \(photos.count)"
    }
    
}