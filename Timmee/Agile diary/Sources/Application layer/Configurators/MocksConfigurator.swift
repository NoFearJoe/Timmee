//
//  MocksConfigurator.swift
//  Agile diary debug
//
//  Created by Илья Харабет on 02/12/2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import Foundation
import TasksKit

protocol MocksConfigurator: AnyObject {
    static func prepareMocks(completion: @escaping () -> Void)
}

final class RuMocksConfigurator: MocksConfigurator {
    
    static func prepareMocks(completion: @escaping () -> Void) {
        let sprint = Sprint(id: "1", number: 2, startDate: Date().startOfDay - 7.asDays, endDate: Date() + 7.asWeeks, duration: 7, notifications: Sprint.Notifications())
        
        let dd1: [Date] = [.now, .now - 1.asDays, .now - 2.asDays, .now - 3.asDays, .now - 4.asDays, .now - 5.asDays, .now - 6.asDays]
        let dd2: [Date] = [.now, .now - 2.asDays, .now - 3.asDays, .now - 6.asDays, .now - 7.asDays]
        let dd3: [Date] = [.now - 1.asDays, .now - 2.asDays, .now - 3.asDays, .now - 4.asDays, .now - 5.asDays, .now - 7.asDays]
        let dueDays: [DayUnit] = [.monday, .friday, .saturday, .sunday, .thusday, .tuesday, .wednesday]
        var n1 = Date.now; n1 => 7.asHours; n1 => 30.asMinutes
        let h1 = Habit(id: "0", title: "Почитать новости", description: "https://www.news.com", value: nil, dueTime: nil, notification: .none, repeatEndingDate: nil, dueDays: dueDays, doneDates: dd1, creationDate: .now - 7.asDays)
        
        var n2 = Date.now; n2 => 7.asHours; n2 => 50.asMinutes
        let h2 = Habit(id: "1", title: "Сделать зарядку", description: "", value: nil, dueTime: nil, notification: .none, repeatEndingDate: nil, dueDays: dueDays, doneDates: dd2, creationDate: .now - 7.asDays)
        
        let h3 = Habit(id: "2", title: "Не пить кофе", description: "", value: nil, dueTime: nil, notification: .none, repeatEndingDate: nil, dueDays: dueDays, doneDates: dd3, creationDate: .now - 7.asDays)
        
        var n4 = Date.now; n4 => 20.asHours; n4 => 00.asMinutes
        let h4 = Habit(id: "3", title: "Английский 15 минут", description: "", value: nil, dueTime: nil, notification: .at(Time(20, 0)), repeatEndingDate: nil, dueDays: dueDays, doneDates: dd1, creationDate: .now - 7.asDays)
        
        let g3 = Goal(id: "0", title: "Набрать 3 килограмма", note: "", isDone: false, creationDate: .now - 7.asDays)
        
        let g2 = Goal(id: "1", title: "Повысить уровень английского", note: "", isDone: false, creationDate: .now - 7.asDays)
        let sg21 = Stage(id: "10", title: "Выучить 500 новых слов", isDone: false, sortPosition: 0, creationDate: .now - 7.asDays)
        let sg22 = Stage(id: "11", title: "Пройти курс разговорного английского", isDone: true, sortPosition: 1, creationDate: .now - 7.asDays)
        let sg23 = Stage(id: "12", title: "Поговорить с носителем языка", isDone: false, sortPosition: 2, creationDate: .now - 7.asDays)
        
        let g1 = Goal(id: "2", title: "Прочитать книги о Гарри Поттере", note: "", isDone: false, creationDate: .now - 7.asDays)
        let sg11 = Stage(id: "00", title: "Философский камень", isDone: true, sortPosition: 0, creationDate: .now - 7.asDays)
        let sg12 = Stage(id: "01", title: "Тайная комната", isDone: true, sortPosition: 1, creationDate: .now - 7.asDays)
        let sg13 = Stage(id: "02", title: "Узник Азкабана", isDone: false, sortPosition: 2, creationDate: .now - 7.asDays)
        let sg14 = Stage(id: "03", title: "Кубок огня", isDone: false, sortPosition: 3, creationDate: .now - 7.asDays)
        let sg15 = Stage(id: "04", title: "Орден феникса", isDone: false, sortPosition: 4, creationDate: .now - 7.asDays)
        let sg16 = Stage(id: "05", title: "Принц полукровка", isDone: false, sortPosition: 5, creationDate: .now - 7.asDays)
        let sg17 = Stage(id: "06", title: "Дары смерти", isDone: false, sortPosition: 6, creationDate: .now - 7.asDays)
        
        var counter = 18
        let group = DispatchGroup()
        (0..<counter).forEach { _ in group.enter() }
        
        let c: (Bool) -> Void = { _ in
            counter -= 1
            group.leave()
        }
        
        let c1 = {
            counter -= 1
            group.leave()
        }
        
        ServicesAssembly.shared.sprintsService.createOrUpdateSprint(sprint, completion: c)
        ServicesAssembly.shared.habitsService.addHabit(h3, sprintID: sprint.id, goalID: nil, completion: c)
        ServicesAssembly.shared.habitsService.addHabit(h4, sprintID: sprint.id, goalID: nil, completion: c)
        ServicesAssembly.shared.habitsService.addHabit(h2, sprintID: sprint.id, goalID: nil, completion: c)
        ServicesAssembly.shared.habitsService.addHabit(h1, sprintID: sprint.id, goalID: nil, completion: c)
        ServicesAssembly.shared.goalsService.addGoal(g1, sprintID: sprint.id, completion: c)
        ServicesAssembly.shared.goalsService.addGoal(g2, sprintID: sprint.id, completion: c)
        ServicesAssembly.shared.goalsService.addGoal(g3, sprintID: sprint.id, completion: c)
        ServicesAssembly.shared.stagesService.addStage(sg11, to: g1, completion: c1)
        ServicesAssembly.shared.stagesService.addStage(sg12, to: g1, completion: c1)
        ServicesAssembly.shared.stagesService.addStage(sg13, to: g1, completion: c1)
        ServicesAssembly.shared.stagesService.addStage(sg14, to: g1, completion: c1)
        ServicesAssembly.shared.stagesService.addStage(sg15, to: g1, completion: c1)
        ServicesAssembly.shared.stagesService.addStage(sg16, to: g1, completion: c1)
        ServicesAssembly.shared.stagesService.addStage(sg17, to: g1, completion: c1)
        ServicesAssembly.shared.stagesService.addStage(sg21, to: g2, completion: c1)
        ServicesAssembly.shared.stagesService.addStage(sg22, to: g2, completion: c1)
        ServicesAssembly.shared.stagesService.addStage(sg23, to: g2, completion: c1)
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
}

final class EnMocksConfigurator: MocksConfigurator {
    
    static func prepareMocks(completion: @escaping () -> Void) {
        let sprint = Sprint(id: "1", number: 2, startDate: Date().startOfDay - 7.asDays, endDate: Date() + 7.asWeeks, duration: 7, notifications: Sprint.Notifications())
        
        let dd1: [Date] = [.now, .now - 1.asDays, .now - 2.asDays, .now - 3.asDays, .now - 4.asDays, .now - 5.asDays, .now - 6.asDays]
        let dd2: [Date] = [.now, .now - 2.asDays, .now - 3.asDays, .now - 6.asDays, .now - 7.asDays]
        let dd3: [Date] = [.now - 1.asDays, .now - 2.asDays, .now - 3.asDays, .now - 4.asDays, .now - 5.asDays, .now - 7.asDays]
        let dueDays: [DayUnit] = [.monday, .friday, .saturday, .sunday, .thusday, .tuesday, .wednesday]
        var n1 = Date.now; n1 => 7.asHours; n1 => 30.asMinutes
        let h1 = Habit(id: "0", title: "Read news", description: "https://www.news.com", value: nil, dueTime: nil, notification: .none, repeatEndingDate: nil, dueDays: dueDays, doneDates: dd1, creationDate: .now - 7.asDays)
        
        var n2 = Date.now; n2 => 7.asHours; n2 => 50.asMinutes
        let h2 = Habit(id: "1", title: "Do morning exercises", description: "", value: nil, dueTime: nil, notification: .none, repeatEndingDate: nil, dueDays: dueDays, doneDates: dd2, creationDate: .now - 7.asDays)
        
        let h3 = Habit(id: "2", title: "Don't drink coffee", description: "", value: nil, dueTime: nil, notification: .none, repeatEndingDate: nil, dueDays: dueDays, doneDates: dd3, creationDate: .now - 7.asDays)
        
        var n4 = Date.now; n4 => 20.asHours; n4 => 00.asMinutes
        let h4 = Habit(id: "3", title: "Learn Chinese 15 minutes", description: "", value: nil, dueTime: nil, notification: .at(Time(20, 0)), repeatEndingDate: nil, dueDays: dueDays, doneDates: dd1, creationDate: .now - 7.asDays)
        
        let g2 = Goal(id: "1", title: "Raise the level of Chinese language", note: "", isDone: false, creationDate: .now - 7.asDays)
        let sg21 = Stage(id: "10", title: "Learn 500 new words", isDone: false, sortPosition: 0, creationDate: .now - 7.asDays)
        let sg22 = Stage(id: "11", title: "Take a course of Chinese language", isDone: true, sortPosition: 1, creationDate: .now - 7.asDays)
        let sg23 = Stage(id: "12", title: "Talk to a native speaker", isDone: false, sortPosition: 2, creationDate: .now - 7.asDays)
        
        let g1 = Goal(id: "2", title: "Read books about Harry Potter", note: "", isDone: false, creationDate: .now - 7.asDays)
        let sg11 = Stage(id: "00", title: "The Philisopher's stone", isDone: true, sortPosition: 0, creationDate: .now - 7.asDays)
        let sg12 = Stage(id: "01", title: "The Chamber of Secrets", isDone: true, sortPosition: 1, creationDate: .now - 7.asDays)
        let sg13 = Stage(id: "02", title: "The prisoner of Azkaban", isDone: false, sortPosition: 2, creationDate: .now - 7.asDays)
        let sg14 = Stage(id: "03", title: "The Goblet of Fire", isDone: false, sortPosition: 3, creationDate: .now - 7.asDays)
        let sg15 = Stage(id: "04", title: "The Order of the Phoenix", isDone: false, sortPosition: 4, creationDate: .now - 7.asDays)
        let sg16 = Stage(id: "05", title: "The Half-Blood Prince", isDone: false, sortPosition: 5, creationDate: .now - 7.asDays)
        let sg17 = Stage(id: "06", title: "The Deathly Hallows", isDone: false, sortPosition: 6, creationDate: .now - 7.asDays)
                
        var counter = 17
        let group = DispatchGroup()
        (0..<counter).forEach { _ in group.enter() }
        
        let c: (Bool) -> Void = { _ in
            counter -= 1
            group.leave()
        }
        
        let c1 = {
            counter -= 1
            group.leave()
        }
        
        ServicesAssembly.shared.sprintsService.createOrUpdateSprint(sprint, completion: c)
        ServicesAssembly.shared.habitsService.addHabit(h3, sprintID: sprint.id, goalID: nil, completion: c)
        ServicesAssembly.shared.habitsService.addHabit(h4, sprintID: sprint.id, goalID: nil, completion: c)
        ServicesAssembly.shared.habitsService.addHabit(h2, sprintID: sprint.id, goalID: nil, completion: c)
        ServicesAssembly.shared.habitsService.addHabit(h1, sprintID: sprint.id, goalID: nil, completion: c)
        ServicesAssembly.shared.goalsService.addGoal(g1, sprintID: sprint.id, completion: c)
        ServicesAssembly.shared.goalsService.addGoal(g2, sprintID: sprint.id, completion: c)
        ServicesAssembly.shared.stagesService.addStage(sg11, to: g1, completion: c1)
        ServicesAssembly.shared.stagesService.addStage(sg12, to: g1, completion: c1)
        ServicesAssembly.shared.stagesService.addStage(sg13, to: g1, completion: c1)
        ServicesAssembly.shared.stagesService.addStage(sg14, to: g1, completion: c1)
        ServicesAssembly.shared.stagesService.addStage(sg15, to: g1, completion: c1)
        ServicesAssembly.shared.stagesService.addStage(sg16, to: g1, completion: c1)
        ServicesAssembly.shared.stagesService.addStage(sg17, to: g1, completion: c1)
        ServicesAssembly.shared.stagesService.addStage(sg21, to: g2, completion: c1)
        ServicesAssembly.shared.stagesService.addStage(sg22, to: g2, completion: c1)
        ServicesAssembly.shared.stagesService.addStage(sg23, to: g2, completion: c1)
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
}

final class PastSprintMocksConfigurator: MocksConfigurator {
    static func prepareMocks(completion: @escaping () -> Void) {
        let sprint = Sprint(id: "0",
                            number: 1,
                            startDate: Date().startOfDay - 8.asWeeks,
                            endDate: Date() - 5.asDays,
                            duration: 7,
                            notifications: Sprint.Notifications())
        
        ServicesAssembly.shared.sprintsService.createOrUpdateSprint(sprint, completion: { _ in
            completion()
        })
    }
}
