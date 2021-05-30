//
//  Habit+init.swift
//  Agile diary
//
//  Created by i.kharabet on 16.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import Foundation
import TasksKit
import UIComponents

extension Habit {
    
    convenience init(habitID: String) {
        self.init(id: habitID,
                  title: "",
                  description: "",
                  value: nil,
                  dueTime: nil,
                  notification: .none,
                  repeatEndingDate: nil,
                  dueDays: DayUnit.all,
                  doneDates: [],
                  creationDate: Date.now)
    }
    
}
