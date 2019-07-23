//
//  List.swift
//  Timmee
//
//  Created by Ilya Kharabet on 23.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date
import class Foundation.NSPredicate
import class UIKit.UIColor
import class UIKit.UIImage
import class CoreData.NSFetchRequest

public class List {
    public var id: String
    public var title: String
    public var note: String
    public var icon: ListIcon
    public var sortPosition: Int
    public let tasksCount: Int
    public var isFavorite: Bool
    public var creationDate: Date
    
    public init(listEntity: ListEntity) {
        id = listEntity.id!
        title = listEntity.title!
        note = listEntity.note ?? ""
        icon = ListIcon(id: Int(listEntity.iconID))
        sortPosition = Int(listEntity.sortPosition)
        tasksCount = listEntity.tasks?.count ?? 0
        isFavorite = listEntity.isFavorite
        creationDate = listEntity.creationDate! as Date
    }
    
    public init(id: String,
                title: String,
                note: String = "",
                icon: ListIcon,
                sortPosition: Int = 0,
                tasksCount: Int = 0,
                isFavorite: Bool = false,
                creationDate: Date) {
        self.id = id
        self.title = title
        self.note = note
        self.icon = icon
        self.sortPosition = sortPosition
        self.tasksCount = tasksCount
        self.isFavorite = isFavorite
        self.creationDate = creationDate
    }
    
    public var copy: List {
        return List(id: id,
                    title: title,
                    note: note,
                    icon: icon,
                    sortPosition: sortPosition,
                    tasksCount: tasksCount,
                    isFavorite: isFavorite,
                    creationDate: creationDate)
    }
    
    public var tasksFetchPredicate: NSPredicate? {
        return NSPredicate(format: "list.id == %@", self.id)
    }
    
    public var defaultDueDate: Date? {
        return nil
    }
}

public extension List {
    final var tasksFetchRequest: NSFetchRequest<TaskEntity> {
        let fetchRequest = NSFetchRequest<TaskEntity>(entityName: "Task")
        fetchRequest.predicate = tasksFetchPredicate
        return fetchRequest
    }
}

extension List: Equatable {
    public static func ==(lhs: List, rhs: List) -> Bool {
        return lhs.id == rhs.id
    }
}

extension List: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
