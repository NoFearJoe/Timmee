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
//    case byTasksCount
    case byName
    
    static let all: [ListSorting] = [.byCreationDate, .byName]
    
    init(value: Int) {
        switch value {
//        case 1: self = .byTasksCount
        case 1: self = .byName
        default: self = .byCreationDate
        }
    }
    
    var next: ListSorting {
        switch self {
        case .byCreationDate: return .byName
//        case .byTasksCount: return .byName
        case .byName: return .byCreationDate
        }
    }
    
    var title: String {
        switch self {
        case .byCreationDate: return "sort_by_creation_date".localized
//        case .byTasksCount: return "sort_by_tasks_count".localized
        case .byName: return "sort_by_title".localized
        }
    }
}

extension ListSorting {

    var sortDescriptor: NSSortDescriptor {
        switch self {
        case .byCreationDate:
            return NSSortDescriptor(key: "creationDate", ascending: true)
//        case .byTasksCount:
//            return NSSortDescriptor(key: "tasks.count", ascending: false)
        case .byName:
            return NSSortDescriptor(key: "title", ascending: true)
        }
    }

}
