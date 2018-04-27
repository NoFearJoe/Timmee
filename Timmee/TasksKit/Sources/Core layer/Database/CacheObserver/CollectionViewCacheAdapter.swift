//
//  CollectionViewCacheAdapter.swift
//  TasksCore
//
//  Created by i.kharabet on 11.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import class UIKit.UICollectionView

public protocol CollectionViewManageble: class {
    func setCollectionView(_ collectionView: UICollectionView)
}

public final class CollectionViewCacheAdapter: CollectionViewManageble, CacheSubscriber {
    
    private weak var collectionView: UICollectionView?
    
    public init() {}
    
    public init(collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    public func setCollectionView(_ collectionView: UICollectionView) {
        self.collectionView = collectionView
    }
    
    public func reloadData() {
        collectionView?.reloadData()
    }
    
    public func processChanges(_ changes: [CoreDataChange], completion: @escaping () -> Void) {
        guard let collectionView = self.collectionView else { return }
        
        collectionView.performBatchUpdates({
            changes.forEach { change in
                switch change {
                case let .sectionInsertion(index):
                    collectionView.insertSections(IndexSet(integer: index))
                case let .sectionDeletion(index):
                    collectionView.deleteSections(IndexSet(integer: index))
                case let .insertion(indexPath):
                    collectionView.insertItems(at: [indexPath])
                case let .deletion(indexPath):
                    collectionView.deleteItems(at: [indexPath])
                case let .update(indexPath):
                    collectionView.reloadItems(at: [indexPath])
                case let .move(fromIndexPath, toIndexPath):
                    collectionView.moveItem(at: fromIndexPath, to: toIndexPath)
                }
            }
        }, completion: { finished in
            print("::2")
            completion()
        })
    }
    
}
