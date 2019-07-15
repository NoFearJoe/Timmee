//
//  PhotoPreviewCollectionLayout.swift
//  Timmee
//
//  Created by i.kharabet on 21.12.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class PhotoPreviewCollectionLayout: UICollectionViewFlowLayout {
    
    fileprivate var lastCollectionViewSize = CGSize.zero
    
    var scalingOffset: CGFloat = 200
    var minimumScaleFactor: CGFloat = 0.75
    var scaleItems = true
    
    
    override init() {
        super.init()
        self.scrollDirection = .horizontal
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.scrollDirection = .horizontal
    }
    
    
    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        
        guard let collectionView = collectionView else { return }
        
        let size = collectionView.bounds.size
        scalingOffset = size.width
        
        if !size.equalTo(self.lastCollectionViewSize) {
            self.configureInset()
            self.lastCollectionViewSize = size
        }
    }
    
    fileprivate func configureInset() -> Void {
        guard let collectionView = collectionView else { return }
        
        let inset = collectionView.bounds.size.width / 2 - self.itemSize.width / 2
        collectionView.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        collectionView.contentOffset = CGPoint(x: -inset, y: 0)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }
        
        let collectionViewSize = collectionView.bounds.size
        let proposedRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionViewSize.width, height: collectionViewSize.height)
        
        let layoutAttributes = self.layoutAttributesForElements(in: proposedRect)
        
        if layoutAttributes == nil {
            return proposedContentOffset
        }
        
        var candidateAttributes: UICollectionViewLayoutAttributes?
        let proposedContentOffsetCenterX = proposedContentOffset.x + collectionViewSize.width / 2
        
        for attributes: UICollectionViewLayoutAttributes in layoutAttributes! {
            if attributes.representedElementCategory != .cell {
                continue
            }
            
            if candidateAttributes == nil {
                candidateAttributes = attributes
                continue
            }
            
            if abs(attributes.center.x - proposedContentOffsetCenterX) < abs(candidateAttributes!.center.x - proposedContentOffsetCenterX) {
                candidateAttributes = attributes
            }
        }
        
        if candidateAttributes == nil {
            return proposedContentOffset
        }
        
        var newOffsetX = candidateAttributes!.center.x - collectionView.bounds.size.width / 2
        
        let offset = newOffsetX - collectionView.contentOffset.x
        
        if (velocity.x < 0 && offset > 0) || (velocity.x > 0 && offset < 0) {
            let pageWidth = self.itemSize.width + self.minimumLineSpacing
            newOffsetX += velocity.x > 0 ? pageWidth : -pageWidth
        }
        
        return CGPoint(x: newOffsetX, y: proposedContentOffset.y)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if !self.scaleItems {
            return super.layoutAttributesForElements(in: rect)
        }
        
        guard let collectionView = collectionView else {
            return super.layoutAttributesForElements(in: rect)
        }
        
        guard let superAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        let contentOffset = collectionView.contentOffset
        let size = collectionView.bounds.size
        
        let visibleRect = CGRect(x: contentOffset.x, y: contentOffset.y, width: size.width, height: size.height)
        let visibleCenterX = visibleRect.midX
        
        var newAttributesArray = [UICollectionViewLayoutAttributes]()
        
        for (_, attributes) in superAttributes.enumerated() {
            let newAttributes = attributes.copy() as! UICollectionViewLayoutAttributes
            newAttributesArray.append(newAttributes)
            let distanceFromCenter = visibleCenterX - newAttributes.center.x
            let absDistanceFromCenter = min(abs(distanceFromCenter), self.scalingOffset)
            let scale = absDistanceFromCenter * (self.minimumScaleFactor - 1) / self.scalingOffset + 1
            newAttributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
        }
        
        return newAttributesArray
    }
    
}
