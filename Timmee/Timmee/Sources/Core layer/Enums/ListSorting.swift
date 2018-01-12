//
//  ListSorting.swift
//  Timmee
//
//  Created by Ilya Kharabet on 31.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foundation.NSSortDescriptor

enum ListSorting: Int {
    case byCreationDateAscending
    case byCreationDateDescending
    case byNameAscending
    case byNameDescending
    
    static let all: [ListSorting] = [.byCreationDateAscending, .byCreationDateDescending, .byNameAscending, .byNameDescending]
    
    init(value: Int) {
        switch value {
        case 1: self = .byCreationDateDescending
        case 2: self = .byNameAscending
        case 3: self = .byNameDescending
        default: self = .byCreationDateAscending
        }
    }
    
    var next: ListSorting {
        switch self {
        case .byCreationDateAscending: return .byCreationDateDescending
        case .byCreationDateDescending: return .byNameAscending
        case .byNameAscending: return .byNameDescending
        case .byNameDescending: return .byCreationDateAscending
        }
    }
    
    var title: String {
        switch self {
        case .byCreationDateAscending: return "sort_by_creation_date_ascending".localized
        case .byCreationDateDescending: return "sort_by_creation_date_descending".localized
        case .byNameAscending: return "sort_by_title_ascending".localized
        case .byNameDescending: return "sort_by_title_descending".localized
        }
    }
}

extension ListSorting {

    var sortDescriptor: NSSortDescriptor {
        switch self {
        case .byCreationDateAscending:
            return NSSortDescriptor(key: "creationDate", ascending: true)
        case .byCreationDateDescending:
            return NSSortDescriptor(key: "creationDate", ascending: false)
        case .byNameAscending:
            return NSSortDescriptor(key: "title", ascending: true)
        case .byNameDescending:
            return NSSortDescriptor(key: "title", ascending: false)
        }
    }

}
