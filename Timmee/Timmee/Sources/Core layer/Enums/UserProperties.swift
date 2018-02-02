//
//  UserProperties.swift
//  Timmee
//
//  Created by Ilya Kharabet on 20.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foundation.UserDefaults

enum UserProperty {
    case isFirstLoad
    case isEducationShown
    case isAppRated
    
    case isInitialSmartListsAdded
    case isDefaultTimeTemplatesAdded
    
    case appTheme
    
    case listSorting
    
    case highlightOverdueTasks
    
    case pinCode
    case biometricsAuthenticationEnabled
    
    case inApp(String)
    
    var rawValue: String {
        switch self {
        case .isFirstLoad: return "isFirstLoad"
        case .isEducationShown: return "isEducationShown"
        case .isAppRated: return "isAppRated"
        case .isInitialSmartListsAdded: return "isInitialSmartListsAdded"
        case .isDefaultTimeTemplatesAdded: return "isDefaultTimeTemplatesAdded"
        case .appTheme: return "appTheme"
        case .listSorting: return "listSorting"
        case .highlightOverdueTasks: return "highlightOverdueTasks"
        case .pinCode: return "pinCode"
        case .biometricsAuthenticationEnabled: return "biometricsAuthenticationEnabled"
        case .inApp(let id): return "inApp_\(id)"
        }
    }
    
}

extension UserProperty {

    func setValue(_ value: Any?) {
        UserDefaults.standard.set(value, forKey: self.rawValue)
    }
    
    func value() -> Any? {
        return UserDefaults.standard.value(forKey: self.rawValue)
    }
    
    func setBool(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: self.rawValue)
    }
    
    func bool() -> Bool {
        return UserDefaults.standard.bool(forKey: self.rawValue)
    }
    
    func setInt(_ value: Int) {
        UserDefaults.standard.set(value, forKey: self.rawValue)
    }
    
    func int() -> Int {
        return UserDefaults.standard.integer(forKey: self.rawValue)
    }
    
    func setString(_ value: String) {
        UserDefaults.standard.set(value, forKey: self.rawValue)
    }
    
    func string() -> String {
        return UserDefaults.standard.string(forKey: self.rawValue) ?? ""
    }

}
