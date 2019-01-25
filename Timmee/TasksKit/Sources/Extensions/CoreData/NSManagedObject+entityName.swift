//
//  NSManagedObject+entityName.swift
//  Timmee
//
//  Created by Илья Харабет on 01.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import func Foundation.NSStringFromClass
import class CoreData.NSFetchRequest
import class CoreData.NSManagedObject

public extension NSManagedObject {
    
    public class var entityName: String {
        return String(describing: self.classForCoder())
    }
    
    public static func request<T: NSManagedObject>() -> FetchRequest<T> {
        return FetchRequest() as FetchRequest<T>
    }
    
}
