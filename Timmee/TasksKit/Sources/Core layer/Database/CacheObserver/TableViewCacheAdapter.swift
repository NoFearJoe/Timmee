//
//  TableViewCacheAdapter.swift
//  TasksCore
//
//  Created by i.kharabet on 11.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import class UIKit.UITableView

public protocol TableViewManageble: class {
    func setTableView(_ tableView: UITableView)
}

public final class TableViewCacheAdapter: TableViewManageble, CacheSubscriber {
    
    private weak var tableView: UITableView?
    
    public init() {}
    
    public init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    public func setTableView(_ tableView: UITableView) {
        self.tableView = tableView
    }
    
    public func reloadData() {
        tableView?.reloadData()
    }
    
    public func prepareToProcessChanges() {
        tableView?.beginUpdates()
    }
    
    public func processChanges(_ changes: [CoreDataChange], completion: @escaping () -> Void) {
        guard let tableView = tableView else { return }
                
        changes.forEach { change in
            switch change {
            case let .sectionInsertion(index):
                tableView.insertSections(IndexSet(integer: index), with: .fade)
            case let .sectionDeletion(index):
                tableView.deleteSections(IndexSet(integer: index), with: .fade)
            case let .insertion(indexPath):
                tableView.insertRows(at: [indexPath], with: .fade)
            case let .deletion(indexPath):
                tableView.deleteRows(at: [indexPath], with: .fade)
            case let .update(indexPath):
                tableView.reloadRows(at: [indexPath], with: .none)
            case let .move(fromIndexPath, toIndexPath):
                if tableView.numberOfSections - 1 < toIndexPath.section {
                    tableView.deleteRows(at: [fromIndexPath], with: .fade)
                } else {
                    tableView.deleteRows(at: [fromIndexPath], with: .fade)
                    tableView.insertRows(at: [toIndexPath], with: .fade)
                }
            }
        }
        
        tableView.endUpdates()
        
        completion()
    }
    
}
