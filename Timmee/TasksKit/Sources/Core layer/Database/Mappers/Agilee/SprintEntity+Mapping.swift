//
//  SprintEntity+Mapping.swift
//  TasksKit
//
//  Created by Илья Харабет on 15/10/2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

public extension SprintEntity {
    
    public func map(from entity: Sprint) {
        id = entity.id
        title = entity.title
        startDate = entity.startDate
        endDate = entity.endDate
    }
    
}
