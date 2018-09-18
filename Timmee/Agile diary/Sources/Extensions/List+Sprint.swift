//
//  List+Sprint.swift
//  Agile diary
//
//  Created by i.kharabet on 14.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import TasksKit

typealias Sprint = List

extension Sprint {
    
    convenience init(number: Int) {
        self.init(id: "sprint_\(number)",
            title: "",
            note: "temporary",
            icon: .allTasks,
            sortPosition: number,
            tasksCount: 0,
            isFavorite: false,
            creationDate: Date().nextDay.startOfDay)
    }
    
}
