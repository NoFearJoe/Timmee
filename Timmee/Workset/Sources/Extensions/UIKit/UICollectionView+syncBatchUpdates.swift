//
//  UICollectionView+syncBatchUpdates.swift
//  Workset
//
//  Created by Илья Харабет on 27.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import class UIKit.UICollectionView

public extension UICollectionView {
    
    private static var syncQueueKey = "sync_queue"
    
    private var syncQueue: DispatchQueue {
        if let queue = objc_getAssociatedObject(self, &UICollectionView.syncQueueKey) as? DispatchQueue {
            return queue
        }
        let queue = DispatchQueue(label: "UICollectionView_sync_queue")
        objc_setAssociatedObject(self, &UICollectionView.syncQueueKey, queue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        return queue
    }
    
    public func performSynchronizedBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        syncQueue.async {
            let group = DispatchGroup()

            DispatchQueue.main.sync {
                print("::enter")
                group.enter()
                self.performBatchUpdates(updates, completion: { _ in
                    group.leave()
                })
                group.notify(queue: .main, execute: {
                    print("::leave")
                    completion?(true)
                })
                
            }
            
            group.wait()
        }
    }
    
}
