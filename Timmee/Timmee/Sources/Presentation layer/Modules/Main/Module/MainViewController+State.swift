//
//  MainViewController+State.swift
//  Timmee
//
//  Created by i.kharabet on 24.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

extension MainViewController {
    
    struct State {
        var currentList: List = SmartList(type: .all)
        var isPickingList: Bool = false
        var pickingListCompletion: ((List) -> Void)?
    }
    
}
