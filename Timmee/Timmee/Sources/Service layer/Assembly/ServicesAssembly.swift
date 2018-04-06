//
//  ServicesAssembly.swift
//  Timmee
//
//  Created by i.kharabet on 04.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

public final class ServicesAssembly {
    
    static let shared = ServicesAssembly()
    
    lazy var tasksService: TasksProvider & TasksObserverProvider & TaskEntitiesCountProvider & TasksManager = PrivateServicesAssembly.shared.tasksService
    
    lazy var listsService: ListsProvider & SmartListsProvider & ListsObserverProvider & ListsManager & SmartListsManager = PrivateServicesAssembly.shared.listsService
    
    lazy var subtasksService: SubtasksProvider & SubtasksManager = PrivateServicesAssembly.shared.subtasksService
    
    lazy var tagsService: TagsProvider & TagsManager = PrivateServicesAssembly.shared.tagsService
    
    lazy var timeTemplatesService: TimeTemplatesProvider & TimeTemplatesManager = PrivateServicesAssembly.shared.timeTemplatesService
    
}

final class PrivateServicesAssembly {
    
    static let shared = PrivateServicesAssembly()
    
    lazy var tasksService:
        TasksProvider &
        TasksObserverProvider &
        TasksManager &
        TaskEntitiesProvider &
        TaskEntitiesBackgroundProvider &
        TaskEntitiesCountProvider = {
            let service = TasksService(listsProvider: listsService,
                                       subtasksProvider: subtasksService,
                                       tagsProvider: tagsService,
                                       timeTemplatesProvider: timeTemplatesService)
            
            (subtasksService as! SubtasksService).tasksProvider = service
            
            return service
        }()
    
    lazy var listsService:
        ListsProvider &
        SmartListsProvider &
        ListEntitiesProvider &
        SmartListEntitiesProvider &
        ListsObserverProvider &
        ListsManager &
        SmartListsManager
        = ListsService()
    
    lazy var subtasksService:
        SubtasksProvider &
        SubtaskEntitiesProvider &
        SubtaskEntitiesBackgroundProvider &
        SubtasksManager
        = SubtasksService()
    
    lazy var tagsService:
        TagsProvider &
        TagEntitiesProvider &
        TagEntitiesBackgroundProvider &
        TagsManager
        = TagsService()
    
    lazy var timeTemplatesService:
        TimeTemplatesProvider &
        TimeTemplateEntitiesProvider &
        TimeTemplateEntitiesBackgroundProvider &
        TimeTemplatesManager
        = TimeTemplatesService()
    
}
