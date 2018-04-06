//
//  InitialDataConfigurator.swift
//  Timmee
//
//  Created by i.kharabet on 31.01.18.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import class Foundation.DispatchQueue
import class Foundation.DispatchGroup

final class InitialDataConfigurator {
    
    private let listsService = ServicesAssembly.shared.listsService
    
    func addInitialSmartLists(completion: @escaping () -> Void) {
        if !listsService.fetchSmartLists().contains(where: { $0.smartListType == .all }) && UserProperty.isInitialSmartListsAdded.bool() {
            addAllTasksSmartList(completion: completion)
        } else {
            addInitialSmartListsIfNeeded(completion: completion)
        }
    }
    
    private func addAllTasksSmartList(completion: @escaping () -> Void) {
        let list = SmartList(type: .all)
        listsService.addSmartList(list, completion: { _ in
            DispatchQueue.main.async {
                completion()
            }
        })
    }
    
    private func addInitialSmartListsIfNeeded(completion: @escaping () -> Void) {
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
