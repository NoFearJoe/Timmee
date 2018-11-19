//
//  List+Sprint.swift
//  Agile diary
//
//  Created by i.kharabet on 14.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import TasksKit
import Workset

extension Sprint {
    
    convenience init(number: Int) {
        self.init(id: "sprint_\(number)",
                  number: number,
                  title: "",
                  startDate: Date.now.startOfDay,
                  endDate: Date.now.startOfDay + Constants.sprintDuration.asWeeks,
                  isReady: false,
                  notifications: Notifications())
    }
    
}
