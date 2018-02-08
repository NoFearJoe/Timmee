//
//  SmartListsPickerState.swift
//  Timmee
//
//  Created by i.kharabet on 07.02.18.
//  Copyright © 2018 Mesterra. All rights reserved.
//

struct SmartListsPickerState {
    
    var smartLists: [SmartList]
    var selectedSmartLists: [SmartList]
    
    var isPerformingOperation: Bool = false
    
}

extension SmartListsPickerState {
    
    init() {
        self.init(smartLists: [], selectedSmartLists: [], isPerformingOperation: false)
    }
    
}
