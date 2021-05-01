//
//  Stage.swift
//  TasksKit
//
//  Created by Илья Харабет on 27.04.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import Foundation

public final class Stage {

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
    
    public convenience init(entity: StageEntity) {
        self.init(id: entity.id ?? "",
                  title: entity.title ?? "",
                  isDone: entity.isDone,
                  sortPosition: Int(entity.sortPosition),
                  creationDate: entity.creationDate! as Date)
    }
    
    public var copy: Stage {
        Stage(
            id: id,
            title: title,
            isDone: isDone,
            sortPosition: sortPosition,
            creationDate: creationDate
        )
    }

}

extension Stage: Equatable {
    public static func == (lhs: Stage, rhs: Stage) -> Bool {
        return lhs.id == rhs.id
            && lhs.title == rhs.title
            && lhs.isDone == rhs.isDone
            && lhs.sortPosition == rhs.sortPosition
    }
}

