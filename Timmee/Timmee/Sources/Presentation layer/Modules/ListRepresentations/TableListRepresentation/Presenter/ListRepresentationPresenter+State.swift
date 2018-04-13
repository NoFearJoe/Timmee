//
//  ListRepresentationPresenter+State.swift
//  Timmee
//
//  Created by i.kharabet on 11.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

extension ListRepresentationPresenter {
    
    struct State {
        var list: List?
        var isClear: Bool = false
        var enteredTaskTitle: String?
        
        var shouldResetOffsetAfterReload: Bool = false
        
        var checkedTasks: [Task] = []
        
        var shouldCreateImportantTask: Bool = false
        
        mutating func reset() {
            shouldResetOffsetAfterReload = false
        }
    }
    
}
