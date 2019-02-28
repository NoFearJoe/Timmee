//
//  Task+Habit.swift
//  Agile diary
//
//  Created by i.kharabet on 16.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import Foundation
import TasksKit

extension Habit {
    
    convenience init(habitID: String) {
        self.init(id: habitID,
                  title: "",
                  note: "",
                  link: "",
                  value: nil,
                  dayTime: .midday,
                  notificationDate: nil,
                  repeatEndingDate: nil,
                  dueDays: DayUnit.all,
                  doneDates: [],
                  creationDate: Date.now)
    }
    
}
