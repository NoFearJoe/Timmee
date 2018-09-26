//
//  Task+Habit.swift
//  Agile diary
//
//  Created by i.kharabet on 16.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import Foundation
import TasksKit

typealias Habit = Task

extension Habit {
    
    convenience init(habitID: String) {
        self.init(id: habitID,
                  kind: "habit",
                  title: "",
                  isImportant: false,
                  notification: .doNotNotify,
                  notificationDate: nil,
                  note: "",
                  link: "",
                  repeating: .init(type: RepeatType.on(WeekRepeatUnit(string: DayUnit.all.map { $0.string }.joined(separator: ",")))),
                  repeatEndingDate: nil,
                  dueDate: nil,
                  location: nil,
                  address: nil,
                  shouldNotifyAtLocation: false,
                  attachments: [],
                  isDone: false,
                  inProgress: false,
                  creationDate: Date.now,
                  doneDates: [])
    }
    
}
