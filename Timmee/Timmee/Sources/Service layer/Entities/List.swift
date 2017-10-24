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

class List {
    var id: String
    var title: String
    var note: String
    var icon: ListIcon
    let creationDate: Date
    
    init(listEntity: ListEntity) {
        id = listEntity.id!
        title = listEntity.title!
        note = listEntity.note ?? ""
        icon = ListIcon(id: Int(listEntity.iconID))
        creationDate = listEntity.creationDate! as Date
    }
    
    init(id: String,
         title: String,
         note: String = "",
         icon: ListIcon,
         creationDate: Date) {
        self.id = id
        self.title = title
        self.note = note
        self.icon = icon
        self.creationDate = creationDate
    }
    
    var copy: List {
        return List(id: id,
                    title: title,
                    note: note,
                    icon: icon,
                    creationDate: creationDate)
    }
    
    var tasksFetchPredicate: NSPredicate? {
        return NSPredicate(format: "list.id == %@", self.id)
    }
}

extension List {
    final var tasksFetchRequest: NSFetchRequest<TaskEntity> {
        let fetchRequest = NSFetchRequest<TaskEntity>(entityName: "Task")
        fetchRequest.predicate = tasksFetchPredicate
        return fetchRequest
    }
}
