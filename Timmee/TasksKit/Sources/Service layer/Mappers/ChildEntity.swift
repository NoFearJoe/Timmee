//
//  ChildEntity.swift
//  TasksKit
//
//  Created by i.kharabet on 12.02.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

public protocol ChildEntity: AnyObject {
    var parent: IdentifiableEntity? { get }
}
