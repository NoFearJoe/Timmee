//
//  GlobalRoutingManager.swift
//  Scope
//
//  Created by i.kharabet on 16/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

enum GlobalRoutingTarget {
    case taskEditor(Task.Kind)
}

final class GlobalRoutingManager {
    
    static let shared = GlobalRoutingManager()
    
    var currentTarget: GlobalRoutingTarget?
    
}
