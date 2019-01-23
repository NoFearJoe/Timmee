//
//  ServicesAssembly.swift
//  Timmee
//
//  Created by i.kharabet on 04.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

public final class ServicesAssembly {
    
    public static let shared = ServicesAssembly()
    
    public lazy var tasksService: TasksProvider & TasksObserverProvider & TaskEntitiesCountProvider & TasksManager = PrivateServicesAssembly.shared.tasksService
    
    public lazy var listsService: ListsProvider & SmartListsProvider & ListsObserverProvider & ListsManager & SmartListsManager = PrivateServicesAssembly.shared.listsService
    
    public lazy var subtasksService: SubtasksProvider & SubtasksManager = PrivateServicesAssembly.shared.subtasksService
    
    public lazy var tagsService: TagsProvider & TagsManager = PrivateServicesAssembly.shared.tagsService
    
    public lazy var timeTemplatesService: TimeTemplatesProvider & TimeTemplatesManager = PrivateServicesAssembly.shared.timeTemplatesService
    
    public lazy var audioRecordService: AudioRecordServiceInput = AudioRecordService()
    
    public lazy var audioPlayerService: AudioPlayerServiceInput = AudioPlayerService()
    
    // MARK: Agilee services
    
    public lazy var sprintsService: SprintsProvider & SprintsManager & SprintsObserverProvider = PrivateServicesAssembly.shared.sprintsService
    
    public lazy var habitsService: HabitsProvider & HabitsManager & HabitsObserverProvider = PrivateServicesAssembly.shared.habitsService
    
    public lazy var goalsService: GoalsProvider & GoalsManager & GoalsObserverProvider = PrivateServicesAssembly.shared.goalsService
    
    public lazy var waterControlService: WaterControlProvider & WaterControlManager = PrivateServicesAssembly.shared.waterControlService

    
}

public final class EntityServicesAssembly {
    
    public static let shared = EntityServicesAssembly()
    
    public lazy var sprintsService: SprintEntitiesProvider = PrivateServicesAssembly.shared.sprintsService
    
    public lazy var habitsService: HabitEntitiesBackgroundProvider = PrivateServicesAssembly.shared.habitsService
    
    public lazy var goalsService: GoalEntitiesBackgroundProvider = PrivateServicesAssembly.shared.goalsService
    
    public lazy var waterControlService: WaterControlEntityBackgroundProvider = PrivateServicesAssembly.shared.waterControlService
    
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
    
    // MARK: Agilee private services
    
    lazy var sprintsService:
        SprintsProvider &
        SprintsManager &
        SprintsObserverProvider &
        SprintEntitiesProvider
        = SprintsService()
    
    lazy var habitsService:
        HabitsProvider &
        HabitsManager &
        HabitsObserverProvider &
        HabitEntitiesProvider &
        HabitEntitiesBackgroundProvider = HabitsService(sprintsProvider: sprintsService)
    
    lazy var goalsService:
        GoalsProvider &
        GoalsManager &
        GoalsObserverProvider &
        GoalEntitiesProvider &
        GoalEntitiesBackgroundProvider = {
            let service = GoalsService(sprintsProvider: sprintsService,
                                       subtasksProvider: subtasksService)
            
            (subtasksService as! SubtasksService).goalsProvider = service
            
            return service
        }()
    
    lazy var waterControlService:
        WaterControlProvider &
        WaterControlEntityBackgroundProvider &
        WaterControlManager
        = WaterControlService()
    
}
