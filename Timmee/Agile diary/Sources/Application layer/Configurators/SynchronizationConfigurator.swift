//
//  SynchronizationConfigurator.swift
//  Agile diary
//
//  Created by i.kharabet on 08.02.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import Authorization
import Synchronization

final class SynchronizationConfigurator {
    
    static func configure() {
        AuthorizationService.initializeAuthorization()
        AgileeSynchronizationService.initializeSynchronization()
        AgileeSynchronizationService.shared.checkSynchronizationConditions = {
            ProVersionPurchase.shared.isPurchased()
        }
    }
    
}
