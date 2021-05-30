//
//  SprintInteractorTrait.swift
//  Agile diary
//
//  Created by i.kharabet on 23.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import Workset
import TasksKit

protocol SprintInteractorTrait: AnyObject {
    var sprintsService: SprintsManager & SprintsObserverProvider & SprintsProvider { get }
    
    func getCurrentSprint() -> Sprint?
    func getNextSprint() -> Sprint?
    func getOrCreateSprint(completion: @escaping (Sprint) -> Void)
    func createNewSprint() -> Sprint
    func saveSprint(_ sprint: Sprint, completion: @escaping (Bool) -> Void)
    func removeSprint(_ sprint: Sprint, completion: @escaping (Bool) -> Void)
}

extension SprintInteractorTrait {
    
    func getCurrentSprint() -> Sprint? {
        let existingSprints = sprintsService.fetchSprints()
        return existingSprints.first(where: { sprint in
            sprint.startDate <= Date.now.startOfDay && sprint.endDate >= Date.now.endOfDay
        })
    }
    
    func getNextSprint() -> Sprint? {
        let existingSprints = sprintsService.fetchSprints()
        return existingSprints.first(where: { sprint in
            sprint.startDate >= Date.now.endOfDay
        })
    }
    
    func getOrCreateSprint(completion: @escaping (Sprint) -> Void) {
        let sprint = createNewSprint()
        sprintsService.createOrUpdateSprint(sprint) { _ in
            completion(sprint)
        }
    }
    
    func createNewSprint() -> Sprint {
        let existingSprints = sprintsService.fetchSprints()
        
        let latestSprint = existingSprints.max(by: { $0.number < $1.number })
        let nextSprintNumber = (latestSprint?.number ?? 0) + 1
        
        let sprint = Sprint(number: nextSprintNumber)
        
        let estimatedStartDate = (latestSprint?.endDate + 1.asDays)?.startOfDay ?? Date.now.startOfDay
        if estimatedStartDate.isLower(than: Date.now.startOfDay) {
            sprint.startDate = Date.now.startOfDay
        } else {
            sprint.startDate = estimatedStartDate
        }
        sprint.endDate = sprint.startDate.endOfDay + sprint.duration.asWeeks
        
        return sprint
    }
    
    func saveSprint(_ sprint: Sprint, completion: @escaping (Bool) -> Void) {
        sprintsService.createOrUpdateSprint(sprint) { isSuccess in
            completion(isSuccess)
        }
    }
    
    func removeSprint(_ sprint: Sprint, completion: @escaping (Bool) -> Void) {
        sprintsService.removeSprint(sprint) { isSuccess in
            completion(isSuccess)
        }
    }
    
}
