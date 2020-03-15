//
//  SynchronizationAvailabilityChecker.swift
//  Synchronization
//
//  Created by i.kharabet on 06.03.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import Authorization

public final class SynchronizationAvailabilityChecker {
    
    public static let shared = SynchronizationAvailabilityChecker()
    
    private init() {}
    
    private let authorizationService = AuthorizationService()
    
    public var checkSynchronizationConditions: (() -> Bool)?
    
    public var synchronizationEnabled: Bool {
        return authorizationService.authorizedUser != nil
            && (checkSynchronizationConditions == nil || checkSynchronizationConditions?() == true)
    }
    
}
