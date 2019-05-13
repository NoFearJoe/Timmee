//
//  CacheObserverProtocols.swift
//  TasksKit
//
//  Created by i.kharabet on 13/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import Foundation

public protocol CacheSubscriber: class {
    func reloadData()
    func prepareToProcessChanges()
    func processChanges(_ changes: [CoreDataChange], completion: @escaping () -> Void)
}

public protocol CacheSubscribable: class {
    func setSubscriber(_ subscriber: CacheSubscriber)
}
