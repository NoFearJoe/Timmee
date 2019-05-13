//
//  CoreDataChange.swift
//  TasksKit
//
//  Created by i.kharabet on 13/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import Foundation

public enum CoreDataChange {
    case sectionInsertion(Int)
    case sectionDeletion(Int)
    case insertion(IndexPath)
    case deletion(IndexPath)
    case update(IndexPath)
    case move(IndexPath, IndexPath)
    
    var indexPath: IndexPath? {
        switch self {
        case let .insertion(indexPath), let .deletion(indexPath), let .update(indexPath): return indexPath
        default: return nil
        }
    }
    
    var moveIndexPaths: (IndexPath, IndexPath)? {
        guard case .move(let from, let to) = self else { return nil }
        return (from, to)
    }
    
    func isEqualByIndexPath(with indexPath: IndexPath) -> Bool {
        return self.indexPath == indexPath || moveIndexPaths?.0 == indexPath || moveIndexPaths?.1 == indexPath
    }
}
