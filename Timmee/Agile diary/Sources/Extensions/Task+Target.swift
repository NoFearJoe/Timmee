//
//  Task+Goal.swift
//  Agile diary
//
//  Created by i.kharabet on 16.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

extension Goal {
    
    convenience init(goalID: String) {
        self.init(id: goalID,
                  title: "",
                  note: "",
                  isDone: false,
                  creationDate: Date.now)
    }
    
}
