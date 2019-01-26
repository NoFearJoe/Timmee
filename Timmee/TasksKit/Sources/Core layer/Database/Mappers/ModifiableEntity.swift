//
//  ModifiableEntity.swift
//  TasksKit
//
//  Created by i.kharabet on 24.01.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

public protocol ModifiableEntity: AnyObject {    
    var modificationDate: TimeInterval { get set }
    
    func updateModificationDate()
}

extension ModifiableEntity {
    public func updateModificationDate() {
        modificationDate = Date().timeIntervalSince1970
    }
}
