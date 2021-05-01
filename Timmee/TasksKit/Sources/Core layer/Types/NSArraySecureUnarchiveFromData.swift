//
//  NSArraySecureUnarchiveFromData.swift
//  TasksKit
//
//  Created by Илья Харабет on 28.04.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import CoreData
import Foundation

public final class NSArraySecureUnarchiveFromData: NSSecureUnarchiveFromDataTransformer {
    
    override public class var allowedTopLevelClasses: [AnyClass] {
        [NSArray.self]
    }
    
    override public class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override public func transformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data as Data)
    }
    
    override public func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let array = value as? NSArray else { return nil }
        
        return try? NSKeyedArchiver.archivedData(withRootObject: array, requiringSecureCoding: true)
    }
    
    public static func registerTransformer() {
        let transformer = NSArraySecureUnarchiveFromData()
        ValueTransformer.setValueTransformer(transformer, forName: NSValueTransformerName("NSArrayValueTransformer"))
    }
    
}
