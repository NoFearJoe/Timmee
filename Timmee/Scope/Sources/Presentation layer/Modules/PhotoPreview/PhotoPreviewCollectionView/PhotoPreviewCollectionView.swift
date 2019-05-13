//
//  PhotoPreviewCollectionView.swift
//  Timmee
//
//  Created by i.kharabet on 20.12.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class PhotoPreviewCollectionView: UICollectionView {
    
    private var numberOfPhotos: Int {
        return dataSource?.collectionView(self, numberOfItemsInSection: 0) ?? 0
    }
    
    var currentIndex: Int {
        let offset = self.contentOffset.x
        let width = bounds.size.width
        return Int(max(0, min(CGFloat(numberOfPhotos), offset / width)))
    }
    
    func scrollToPhoto(at index: Int, animated: Bool) {
        let targetIndex = max(0, min(numberOfPhotos, index))
        
        let targetOffsetX = CGFloat(targetIndex) * bounds.size.width
        
        setContentOffset(CGPoint(x: targetOffsetX, y: contentOffset.y), animated: animated)
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        decelerationRate = UIScrollView.DecelerationRate.fast
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        decelerationRate = UIScrollView.DecelerationRate.fast
    }
    
}
