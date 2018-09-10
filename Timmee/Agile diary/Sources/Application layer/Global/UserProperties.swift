//
//  UserProperties.swift
//  Agile diary
//
//  Created by i.kharabet on 13.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import class Foundation.UserDefaults

public enum UserProperty: UserPropertyProtocol {
    case isFirstLoad
    case isEducationShown
    case isAppRated
    
    case isInitialSprintCreated
    
    case pinCode
    case biometricsAuthenticationEnabled
    
    case inApp(String)
    
    public var key: String {
        switch self {
        case .isFirstLoad: return "isFirstLoad"
        case .isEducationShown: return "isEducationShown"
        case .isAppRated: return "isAppRated"
        case .isInitialSprintCreated: return "isInitialSmartListsAdded"
        case .pinCode: return "pinCode"
        case .biometricsAuthenticationEnabled: return "biometricsAuthenticationEnabled"
        case .inApp(let id): return "inApp_\(id)"
        }
    }
    
}
