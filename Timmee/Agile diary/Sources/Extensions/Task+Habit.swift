//
//  Task+Habit.swift
//  Agile diary
//
//  Created by i.kharabet on 16.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

typealias Habit = Task

extension Habit {
    
    convenience init(id: String) {
        self.init(id: id,
                  kind: "habit",
                  title: "",
                  isImportant: false,
                  notification: .doNotNotify,
                  notificationDate: Date(),
                  note: "",
                  repeating: .init(type: RepeatType.on(WeekRepeatUnit(string: DayUnit.all.map { $0.string }.joined(separator: ",")))),
                  repeatEndingDate: nil,
                  dueDate: nil,
                  location: nil,
                  address: nil,
                  shouldNotifyAtLocation: false,
                  attachments: [],
                  isDone: false,
                  inProgress: false,
                  creationDate: Date())
    }
    
}
