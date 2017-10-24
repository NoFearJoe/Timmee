//
//  Subtask.swift
//  Timmee
//
//  Created by Ilya Kharabet on 05.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import Foundation

final class Subtask {

    let id: String
    var title: String
    var isDone: Bool
    var sortPosition: Int
    let creationDate: Date
    
    init(id: String, title: String, isDone: Bool, sortPosition: Int, creationDate: Date) {
        self.id = id
        self.title = title
        self.isDone = isDone
        self.sortPosition = sortPosition
        self.creationDate = creationDate
    }
    
    convenience init(id: String, title: String, sortPosition: Int) {
        self.init(id: id,
                  title: title,
                  isDone: false,
                  sortPosition: sortPosition,
                  creationDate: Date())
    }
    
    convenience init(entity: SubtaskEntity) {
        self.init(id: entity.id ?? "",
                  title: entity.title ?? "",
                  isDone: entity.isDone,
                  sortPosition: Int(entity.sortPosition),
                  creationDate: entity.creationDate! as Date)
    }
    
    var copy: Subtask {
        return Subtask(id: id,
                       title: title,
                       isDone: isDone,
                       sortPosition: sortPosition,
                       creationDate: creationDate)
    }

}
