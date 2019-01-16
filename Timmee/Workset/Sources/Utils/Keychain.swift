//
//  Keychain.swift
//  Workset
//
//  Created by i.kharabet on 16.01.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import Foundation

public class Keychain {
    
    public static func read(_ key: String, groupName: String? = nil) -> String? {
        var keychainQuery: [AnyHashable: Any] = [
            kSecClass as AnyHashable: kSecClassGenericPassword,
            kSecAttrAccount as AnyHashable: key,
            kSecReturnData as AnyHashable: kCFBooleanTrue,
            kSecMatchLimit as AnyHashable: kSecMatchLimitOne
        ]
        
        if let groupName = groupName {
            keychainQuery[kSecAttrAccessGroup as AnyHashable] = groupName
        }
        
        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(keychainQuery as CFDictionary, UnsafeMutablePointer($0))
        }
        
        guard status == errSecSuccess else { return nil }
        guard let data = result as? Data else { return nil }
        guard let value = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        
        return value as String
    }
    
    public static func delete(_ key: String, groupName: String? = nil) {
        var keychainQuery: [AnyHashable: Any] = [
            kSecClass as AnyHashable: kSecClassGenericPassword,
            kSecAttrAccount as AnyHashable: key
        ]
        
        if let groupName = groupName {
            keychainQuery[kSecAttrAccessGroup as AnyHashable] = groupName
        }
        
        SecItemDelete(keychainQuery as CFDictionary)
    }
    
    public static func save(_ key: String,
                            value: String,
                            groupName: String? = nil,
                            accessibleAttribute: CFString = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly) {
        self.delete(key, groupName: groupName)
        
        guard let dataFromString = value.data(using: String.Encoding.utf8, allowLossyConversion: false) else { return }
        
        var keychainQuery: [AnyHashable: Any] = [
            kSecClass as AnyHashable: kSecClassGenericPassword,
            kSecAttrAccessible as AnyHashable: accessibleAttribute,
            kSecAttrAccount as AnyHashable: key,
            kSecValueData as AnyHashable: dataFromString
        ]
        
        if let groupName = groupName {
            keychainQuery[kSecAttrAccessGroup as AnyHashable] = groupName
        }
        
        SecItemAdd(keychainQuery as CFDictionary, nil)
    }
    
}
