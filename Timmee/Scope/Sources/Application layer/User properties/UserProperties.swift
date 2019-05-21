//
//  UserProperties.swift
//  Timmee
//
//  Created by Ilya Kharabet on 20.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import Workset
import class Foundation.UserDefaults

public enum UserProperty: UserPropertyProtocol {
    case isFirstLoad
    case isEducationShown
    case isAppRated
    
    case isInitialSmartListsAdded
    case isDefaultTimeTemplatesAdded
    
    case appTheme
    
    case highlightOverdueTasks
    
    case pinCode
    case biometricsAuthenticationEnabled
    
    case inApp(String)
    
    public var key: String {
        switch self {
        case .isFirstLoad: return "isFirstLoad"
        case .isEducationShown: return "isEducationShown"
        case .isAppRated: return "isAppRated"
        case .isInitialSmartListsAdded: return "isInitialSmartListsAdded"
        case .isDefaultTimeTemplatesAdded: return "isDefaultTimeTemplatesAdded"
        case .appTheme: return "appTheme"
        case .highlightOverdueTasks: return "highlightOverdueTasks"
        case .pinCode: return "pinCode"
        case .biometricsAuthenticationEnabled: return "biometricsAuthenticationEnabled"
        case .inApp(let id): return "inApp_\(id)"
        }
    }
    
}
