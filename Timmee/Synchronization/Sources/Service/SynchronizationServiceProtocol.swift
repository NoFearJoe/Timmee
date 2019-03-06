//
//  SynchronizationServiceProtocol.swift
//  Synchronization
//
//  Created by i.kharabet on 06.03.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

public protocol SynchronizationService: AnyObject {
    func sync(completion: ((Bool) -> Void)?)
}
