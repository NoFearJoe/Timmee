//
//  Task+Target.swift
//  Agile diary
//
//  Created by i.kharabet on 16.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

typealias Target = Task

extension Target {
    
    convenience init(targetID: String) {
        self.init(id: targetID,
                  kind: "target",
                  title: "",
                  isImportant: false,
                  notification: .doNotNotify,
                  notificationDate: nil,
                  note: "",
                  link: "",
                  repeating: .init(type: .never),
                  repeatEndingDate: nil,
                  dueDate: nil,
                  location: nil,
                  address: nil,
                  shouldNotifyAtLocation: false,
                  attachments: [],
                  isDone: false,
                  inProgress: false,
                  creationDate: Date(),
                  doneDates: [])
    }
    
}
