//
//  InitialDataConfigurator.swift
//  Timmee
//
//  Created by i.kharabet on 31.01.18.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import class Foundation.DispatchGroup

final class InitialDataConfigurator {
    
    let listsService = ListsService()
    
    func addInitialSmartLists(completion: @escaping () -> Void) {
        guard !UserProperty.isInitialSmartListsAdded.bool() else {
            completion()
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        SmartListType.allValues.prefix(upTo: 3).forEach { listType in
            dispatchGroup.enter()
            let list = SmartList(type: listType)
            listsService.addSmartList(list, completion: { _ in
                dispatchGroup.leave()
            })
        }
        
        dispatchGroup.notify(queue: .main) {
            UserProperty.isInitialSmartListsAdded.setBool(true)
            completion()
        }
    }
    
}
