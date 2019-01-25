//
//  IdentifiableEntity.swift
//  TasksKit
//
//  Created by i.kharabet on 24.01.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

public protocol IdentifiableEntity: AnyObject {
    var id: String? { get set }
}
