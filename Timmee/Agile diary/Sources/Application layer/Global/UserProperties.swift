//
//  UserProperties.swift
//  Agile diary
//
//  Created by i.kharabet on 13.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import class Foundation.UserDefaults
import protocol Workset.UserPropertyProtocol

public enum UserProperty: UserPropertyProtocol {
    case isFirstLoad
    case isEducationShown
    case isAppRated
    
    case isGoalCreationOnboardingShown
    
    case pinCode
    case biometricsAuthenticationEnabled
    
    case inApp(String)
    
    case appTheme
    
    case backgroundImage
    
    public var key: String {
        switch self {
        case .isFirstLoad: return "isFirstLoad"
        case .isEducationShown: return "isEducationShown"
        case .isAppRated: return "isAppRated"
        case .isGoalCreationOnboardingShown: return "isGoalCreationOnboardingShown"
        case .pinCode: return "pinCode"
        case .biometricsAuthenticationEnabled: return "biometricsAuthenticationEnabled"
        case .inApp(let id): return "inApp_\(id)"
        case .appTheme: return "appTheme"
        case .backgroundImage: return "backgroundImage"
        }
    }
    
}
