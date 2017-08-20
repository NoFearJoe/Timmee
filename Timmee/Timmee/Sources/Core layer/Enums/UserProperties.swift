//
//  UserProperties.swift
//  Timmee
//
//  Created by Ilya Kharabet on 20.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foundation.UserDefaults

enum UserProperty: String {
    case isFirstLoad
    case isEducationShown
    case isProtected
}

extension UserProperty {

    func setValue(_ value: Any) {
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

}
