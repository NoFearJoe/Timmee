//
//  ModifiableEntity.swift
//  TasksKit
//
//  Created by i.kharabet on 24.01.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

public protocol ModifiableEntity: AnyObject {    
    var modificationDate: TimeInterval { get set }
    var modificationAuthor: String? { get set }
    
    func updateModificationDate()
    func updateModificationAuthor()
}

extension ModifiableEntity {
    public func updateModificationDate() {
        modificationDate = Date().timeIntervalSince1970
    }
    
    public static var currentAuthor: String? { return UIDevice.current.identifierForVendor?.uuidString }
    
    public func updateModificationAuthor() {
        modificationAuthor = Self.currentAuthor
    }
}
