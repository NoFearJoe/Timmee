//
//  Subtask.swift
//  Timmee
//
//  Created by Ilya Kharabet on 05.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import Foundation

public final class Subtask {

    public let id: String
    public var title: String
    public var isDone: Bool
    public var sortPosition: Int
    public let creationDate: Date
    
    public init(id: String, title: String, isDone: Bool, sortPosition: Int, creationDate: Date) {
        self.id = id
        self.title = title
        self.isDone = isDone
        self.sortPosition = sortPosition
        self.creationDate = creationDate
    }
    
    public convenience init(id: String, title: String, sortPosition: Int) {
        self.init(id: id,
                  title: title,
                  isDone: false,
                  sortPosition: sortPosition,
                  creationDate: Date())
    }
    
    public convenience init(entity: SubtaskEntity) {
        self.init(id: entity.id ?? "",
                  title: entity.title ?? "",
                  isDone: entity.isDone,
                  sortPosition: Int(entity.sortPosition),
                  creationDate: entity.creationDate! as Date)
    }
    
    public var copy: Subtask {
        return Subtask(id: id,
                       title: title,
                       isDone: isDone,
                       sortPosition: sortPosition,
                       creationDate: creationDate)
    }

}

extension Subtask: Equatable {
    public static func == (lhs: Subtask, rhs: Subtask) -> Bool {
        return lhs.id == rhs.id
            && lhs.title == rhs.title
            && lhs.isDone == rhs.isDone
            && lhs.sortPosition == rhs.sortPosition
    }
}
