//
//  ListSorting.swift
//  Timmee
//
//  Created by Ilya Kharabet on 31.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foundation.NSSortDescriptor

enum ListSorting: Int {
    case byCreationDate
    case byTasksCount
    case byName
    
    static let all: [ListSorting] = [.byCreationDate, .byTasksCount, .byName]
    
    init(value: Int) {
        switch value {
        case 1: self = .byTasksCount
        case 2: self = .byName
        default: self = .byCreationDate
        }
    }
}

extension ListSorting {

    var sortDescriptor: NSSortDescriptor {
        switch self {
        case .byCreationDate:
            return NSSortDescriptor(key: "creationDate", ascending: true)
        case .byTasksCount:
            return NSSortDescriptor(key: "tasks.count", ascending: false)
        case .byName:
            return NSSortDescriptor(key: "title", ascending: true)
        }
    }

}
