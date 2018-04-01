//
//  NSManagedObject+entityName.swift
//  Timmee
//
//  Created by Илья Харабет on 01.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import func Foundation.NSStringFromClass
import class CoreData.NSManagedObject

extension NSManagedObject {
    
    class var entityName: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
}
