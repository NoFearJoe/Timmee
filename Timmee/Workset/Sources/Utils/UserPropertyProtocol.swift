//
//  UserPropertyProtocol.swift
//  Workset
//
//  Created by i.kharabet on 13.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import class Foundation.UserDefaults

public protocol UserPropertyRepresentable {
    static var asUserProperty: UserPropertyProtocol { get }
}

public protocol UserPropertyProtocol {
    var key: String { get }
}

extension UserPropertyProtocol {
    
    public func setValue(_ value: Any?) {
        UserDefaults.standard.set(value, forKey: self.key)
    }
    
    public func value() -> Any? {
        return UserDefaults.standard.value(forKey: self.key)
    }
    
    public func setBool(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: self.key)
    }
    
    public func bool() -> Bool {
        return UserDefaults.standard.bool(forKey: self.key)
    }
    
    public func setInt(_ value: Int) {
        UserDefaults.standard.set(value, forKey: self.key)
    }
    
    public func int() -> Int {
        return UserDefaults.standard.integer(forKey: self.key)
    }
    
    public func setString(_ value: String) {
        UserDefaults.standard.set(value, forKey: self.key)
    }
    
    public func string() -> String {
        return UserDefaults.standard.string(forKey: self.key) ?? ""
    }
    
}
