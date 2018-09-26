//
//  SprintInteractorTrait.swift
//  Agile diary
//
//  Created by i.kharabet on 23.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import Workset
import TasksKit

protocol SprintInteractorTrait: class {
    var sprintsService: ListsManager & ListsObserverProvider & ListsProvider & SmartListsManager & SmartListsProvider { get }
    
    func getCurrentSprint() -> Sprint?
    func getNextSprint() -> Sprint?
    func getOrCreateSprint(completion: @escaping (Sprint) -> Void)
    func saveSprint(_ sprint: Sprint, completion: @escaping (Bool) -> Void)
    func removeSprint(_ sprint: Sprint, completion: @escaping (Bool) -> Void)
}

extension SprintInteractorTrait {
    
    func getCurrentSprint() -> Sprint? {
        let existingSprints = sprintsService.fetchLists()
        return existingSprints.first(where: { sprint in
            sprint.creationDate <= Date.now.startOfDay && sprint.endDate >= Date.now.endOfDay
        })
    }
    
    func getNextSprint() -> Sprint? {
        let existingSprints = sprintsService.fetchLists()
        return existingSprints.first(where: { sprint in
            sprint.creationDate >= Date.now.endOfDay
        })
    }
    
    func getOrCreateSprint(completion: @escaping (Sprint) -> Void) {
        let existingSprints = sprintsService.fetchLists()
        if let temporarySprint = existingSprints.first(where: { $0.note == "temporary" }) {
            completion(temporarySprint)
        } else {
            let latestSprint = existingSprints.max(by: { $0.sortPosition < $1.sortPosition })
            let nextSprintNumber = (latestSprint?.sortPosition ?? 0) + 1
            let sprint = Sprint(number: nextSprintNumber)
            sprintsService.createOrUpdateList(sprint, tasks: []) { _ in
                completion(sprint)
            }
        }
    }
    
    func saveSprint(_ sprint: Sprint, completion: @escaping (Bool) -> Void) {
        sprintsService.createOrUpdateList(sprint, tasks: []) { error in
            completion(error == nil)
        }
    }
    
    func removeSprint(_ sprint: Sprint, completion: @escaping (Bool) -> Void) {
        sprintsService.removeList(sprint) { error in
            completion(error == nil)
        }
    }
    
}
