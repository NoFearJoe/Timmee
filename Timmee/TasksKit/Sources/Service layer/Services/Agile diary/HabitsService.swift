//
//  HabitsService.swift
//  TasksKit
//
//  Created by i.kharabet on 16.10.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import Workset

public protocol HabitsProvider: class {
    func fetchHabit(id: String) -> Habit?
    func fetchHabits(sprintID: String) -> [Habit]
}

public protocol HabitsManager: class {
    func addHabit(_ habit: Habit, sprintID: String, completion: @escaping (Bool) -> Void)
    func updateHabit(_ habit: Habit, completion: @escaping (Bool) -> Void)
    func updateHabit(_ habit: Habit, sprintID: String?, completion: @escaping (Bool) -> Void)
    func updateHabits(_ habits: [Habit], completion: @escaping (Bool) -> Void)
    func updateHabits(_ habits: [Habit], sprintID: String?, completion: @escaping (Bool) -> Void)
    func removeHabit(_ habit: Habit, completion: @escaping (Bool) -> Void)
    func removeHabits(_ habits: [Habit], completion: @escaping (Bool) -> Void)
    func updateHabitsNotificationDates(completion: @escaping () -> Void)
    func setRepeatEndingDateForAllHabitsIfNeeded(completion: @escaping () -> Void)
}

public protocol HabitsObserverProvider: class {
    func habitsObserver(sprintID: String, day: DayUnit?) -> CacheObserver<Habit>
    func habitsBySprintObserver(excludingSprintWithID sprintID: String) -> CacheObserver<Habit>
    func habitsScope(sprintID: String, day: DayUnit?) -> CachedEntitiesObserver<HabitEntity, Habit>
}

public protocol HabitEntitiesProvider: class {
    func fetchHabitEntity(id: String) -> HabitEntity?
}

public protocol HabitEntitiesBackgroundProvider: class {
    func fetchHabitEntitiesInBackground(sprintID: String) -> [HabitEntity]
    func fetchHabitEntityInBackground(id: String) -> HabitEntity?
    func fetchAllHabitsInBackground() -> [HabitEntity]
    func fetchHabitEntitiesToUpdateNotificationDateInBackground() -> [HabitEntity]
}

public final class HabitsService {
    
    private let sprintsProvider: SprintEntitiesProvider
    
    init(sprintsProvider: SprintEntitiesProvider) {
        self.sprintsProvider = sprintsProvider
    }
    
    private func createHabit() -> HabitEntity {
        return HabitEntity(context: Database.localStorage.writeContext)
    }
    
}

extension HabitsService: HabitsProvider {
    
    public func fetchHabit(id: String) -> Habit? {
        guard let entity = fetchHabitEntity(id: id) else { return nil }
        return Habit(habit: entity)
    }
    
    public func fetchHabits(sprintID: String) -> [Habit] {
        return HabitsService.habitsFetchRequest(sprintID: sprintID)
            .execute()
            .map { Habit(habit: $0) }
    }
    
}

extension HabitsService: HabitsManager {
    
    public func addHabit(_ habit: Habit, sprintID: String, completion: @escaping (Bool) -> Void) {
        Database.localStorage.write({ (context, save) in
            guard self.fetchHabitEntityInBackground(id: habit.id) == nil else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            let newHabit = self.createHabit()
            newHabit.map(from: habit)
            newHabit.sprint = self.sprintsProvider.fetchSprintEntity(id: sprintID, context: context)
            
            save()
        }) { isSuccess in
            DispatchQueue.main.async { completion(isSuccess) }
        }
    }
    
    public func updateHabit(_ habit: Habit, completion: @escaping (Bool) -> Void) {
        updateHabit(habit, sprintID: nil, completion: completion)
    }
    
    public func updateHabit(_ habit: Habit, sprintID: String?, completion: @escaping (Bool) -> Void) {
        updateHabits([habit], sprintID: sprintID, completion: completion)
    }
    
    public func updateHabits(_ habits: [Habit], completion: @escaping (Bool) -> Void) {
        updateHabits(habits, sprintID: nil, completion: completion)
    }
    
    public func updateHabits(_ habits: [Habit], sprintID: String?, completion: @escaping (Bool) -> Void) {
        guard !habits.isEmpty else {
            DispatchQueue.main.async { completion(false) }
            return
        }
        
        Database.localStorage.write({ (context, save) in
            habits.forEach { habit in
                let habitEntity = self.fetchHabitEntityInBackground(id: habit.id) ?? self.createHabit()
                
                habitEntity.map(from: habit)
                
                if let sprintID = sprintID {
                    habitEntity.sprint = self.sprintsProvider.fetchSprintEntity(id: sprintID,
                                                                                context: context)
                }
            }
            
            save()
        }) { isSuccess in
            DispatchQueue.main.async { completion(isSuccess) }
        }
    }
    
    public func removeHabit(_ habit: Habit, completion: @escaping (Bool) -> Void) {
        removeHabits([habit], completion: completion)
    }
    
    public func removeHabits(_ habits: [Habit], completion: @escaping (Bool) -> Void) {
        guard !habits.isEmpty else {
            DispatchQueue.main.async { completion(false) }
            return
        }
        
        Database.localStorage.write({ (context, save) in
            habits.forEach { habit in
                guard let existingHabit = self.fetchHabitEntityInBackground(id: habit.id) else { return }
                context.delete(existingHabit)
            }
            
            save()
        }) { isSuccess in
            DispatchQueue.main.async { completion(isSuccess) }
        }
    }
    
    public func updateHabitsNotificationDates(completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            let habitsToUpdate = self.fetchHabitEntitiesToUpdateNotificationDateInBackground()
            let updatedHabits = habitsToUpdate.map { entity -> Habit in
                let habit = Habit(habit: entity)
                habit.notificationDate = habit.nextNotificationDate
                return habit
            }
            self.updateHabits(updatedHabits, completion: { _ in
                completion()
            })
        }
    }
    
    public func setRepeatEndingDateForAllHabitsIfNeeded(completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            let habitsToUpdate = self.fetchAllHabitsInBackground()
            let updatedHabits = habitsToUpdate.map { entity -> Habit in
                let habit = Habit(habit: entity)
                habit.repeatEndingDate = entity.sprint?.endDate
                return habit
            }
            self.updateHabits(updatedHabits, completion: { _ in
                completion()
            })
        }
    }
    
}

extension HabitsService: HabitsObserverProvider {
    
    public func habitsObserver(sprintID: String, day: DayUnit?) -> CacheObserver<Habit> {
        let predicate: NSPredicate
        if let day = day {
            predicate = NSPredicate(format: "sprint.id = %@ AND dueDays CONTAINS[cd] %@", sprintID, day.string)
        } else {
            predicate = NSPredicate(format: "sprint.id = %@", sprintID)
        }
        let request = HabitsService.allHabitsFetchRequest().filtered(predicate: predicate).batchSize(10).nsFetchRequestWithResult
        let context = Database.localStorage.readContext
        let habitsObserver = CacheObserver<Habit>(request: request,
                                                  section: nil,
                                                  cacheName: nil,
                                                  context: context)
        
        habitsObserver.setMapping { entity in
            let entity = entity as! HabitEntity
            return Habit(habit: entity)
        }
        
        return habitsObserver
    }
    
    public func habitsBySprintObserver(excludingSprintWithID sprintID: String) -> CacheObserver<Habit> {
        let predicate = NSPredicate(format: "sprint.id != %@", sprintID)
        let request = HabitEntity.request()
            .filtered(predicate: predicate)
            .sorted(keyPath: \HabitEntity.sprint?.number, ascending: true)
            .sorted(keyPath: \.title, ascending: true)
            .sorted(keyPath: \.creationDate, ascending: false)
            .batchSize(10)
            .nsFetchRequestWithResult
        let context = Database.localStorage.readContext
        
        let habitsObserver = CacheObserver<Habit>(request: request,
                                                  section: "sprint.number",
                                                  cacheName: nil,
                                                  context: context)
        
        habitsObserver.setMapping { entity in
            let entity = entity as! HabitEntity
            return Habit(habit: entity)
        }
        
        return habitsObserver
    }
    
    public func habitsScope(sprintID: String, day: DayUnit?) -> CachedEntitiesObserver<HabitEntity, Habit> {
        let predicate: NSPredicate
        if let day = day {
            predicate = NSPredicate(format: "sprint.id = %@ AND dueDays CONTAINS[cd] %@", sprintID, day.string)
        } else {
            predicate = NSPredicate(format: "sprint.id = %@", sprintID)
        }
        let request = HabitsService.allHabitsFetchRequest().filtered(predicate: predicate).batchSize(10).nsFetchRequest
        let context = Database.localStorage.readContext
        
        let observer = CachedEntitiesObserver<HabitEntity, Habit>(context: context,
                                                                  baseRequest: request,
                                                                  grouping: { $0.calculatedDayTime.sortID },
                                                                  mapping: { Habit(habit: $0) })
        
        return observer
    }
    
}

extension HabitsService: HabitEntitiesProvider {
    
    public func fetchHabitEntity(id: String) -> HabitEntity? {
        return HabitsService.habitFetchRequest(id: id).execute().first
    }
    
}

extension HabitsService: HabitEntitiesBackgroundProvider {
    
    public func fetchHabitEntitiesInBackground(sprintID: String) -> [HabitEntity] {
        return HabitsService.habitsFetchRequest(sprintID: sprintID).executeInBackground()
    }
    
    public func fetchHabitEntityInBackground(id: String) -> HabitEntity? {
        return HabitsService.habitFetchRequest(id: id).executeInBackground().first
    }
    
    public func fetchAllHabitsInBackground() -> [HabitEntity] {
        return HabitsService.allHabitsFetchRequest().executeInBackground()
    }
    
    public func fetchHabitEntitiesToUpdateNotificationDateInBackground() -> [HabitEntity] {
        return HabitsService.habitsToUpdateNotificationDateFetchRequest().executeInBackground()
    }
    
}

private extension HabitsService {
    
    static func habitFetchRequest(id: String) -> FetchRequest<HabitEntity> {
        return HabitEntity.request().filtered(key: "id", value: id)
    }
    
    static func habitsFetchRequest(sprintID: String) -> FetchRequest<HabitEntity> {
        return HabitEntity.request().filtered(key: "sprint.id", value: sprintID)
    }
    
    static func allHabitsFetchRequest() -> FetchRequest<HabitEntity> {
        return HabitEntity.request()
            .sorted(keyPath: \.title, ascending: true)
            .sorted(keyPath: \.creationDate, ascending: false)
    }
    
    static func habitsToUpdateNotificationDateFetchRequest() -> FetchRequest<HabitEntity> {
        let predicate = NSPredicate(format: "notificationDate != nil AND notificationDate < %@", NSDate())
        return HabitEntity.request().filtered(predicate: predicate)
    }
    
}
