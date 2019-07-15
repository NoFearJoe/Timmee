//
//  TableListRepresentationPresenter+State.swift
//  Timmee
//
//  Created by i.kharabet on 12.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

extension TableListRepresentationPresenter {
    
    struct State {
        var list: List?
        
        var shouldResetOffsetAfterReload: Bool = false
        
        var checkedTasks: [Task] = []
        
        var editingMode: ListRepresentationEditingMode = .default
                
        mutating func reset() {
            shouldResetOffsetAfterReload = false
        }
    }
    
}
