//
//  MocksConfigurator.swift
//  Agile diary debug
//
//  Created by Илья Харабет on 02/12/2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import Foundation
import TasksKit

protocol MocksConfigurator: class {
    static func prepareMocks(completion: @escaping () -> Void)
}

final class RuMocksConfigurator: MocksConfigurator {
    
    static func prepareMocks(completion: @escaping () -> Void) {
        let sprint = Sprint(id: "0", number: 1, title: "Sprint #1", startDate: Date().startOfDay - 7.asDays, endDate: Date() + 7.asWeeks, isReady: true, notifications: Sprint.Notifications())
        
        let dd1: [Date] = [.now, .now - 1.asDays, .now - 2.asDays, .now - 3.asDays, .now - 4.asDays, .now - 5.asDays, .now - 6.asDays]
        let dd2: [Date] = [.now, .now - 2.asDays, .now - 3.asDays, .now - 6.asDays, .now - 7.asDays]
        let dd3: [Date] = [.now - 1.asDays, .now - 2.asDays, .now - 3.asDays, .now - 4.asDays, .now - 5.asDays, .now - 7.asDays]
        let dueDays: [DayUnit] = [.monday, .friday, .saturday, .sunday, .thusday, .tuesday, .wednesday]
        var n1 = Date.now; n1 => 7.asHours; n1 => 30.asMinutes
        let h1 = Habit(id: "0", title: "Почитать новости", note: "", link: "https://www.news.com", notificationDate: n1, repeatEndingDate: nil, dueDays: dueDays, doneDates: dd1, creationDate: .now)
        
        var n2 = Date.now; n2 => 7.asHours; n2 => 50.asMinutes
        let h2 = Habit(id: "1", title: "Сделать зарядку", note: "", link: "", notificationDate: n2, repeatEndingDate: nil, dueDays: dueDays, doneDates: dd2, creationDate: .now)
        
        let h3 = Habit(id: "2", title: "Не пить кофе", note: "", link: "", notificationDate: nil, repeatEndingDate: nil, dueDays: dueDays, doneDates: dd3, creationDate: .now)
        
        var n4 = Date.now; n4 => 20.asHours; n4 => 00.asMinutes
        let h4 = Habit(id: "3", title: "Английский 15 минут", note: "", link: "", notificationDate: n4, repeatEndingDate: nil, dueDays: dueDays, doneDates: dd1, creationDate: .now)
        
        let g3 = Goal(id: "0", title: "Набрать 3 килограмма", note: "", isDone: false, creationDate: .now)
        
        let g2 = Goal(id: "1", title: "Повысить уровень английского", note: "", isDone: false, creationDate: .now)
        let sg21 = Subtask(id: "10", title: "Выучить 500 новых слов", isDone: false, sortPosition: 0, creationDate: .now)
        let sg22 = Subtask(id: "11", title: "Пройти курс разговорного английского", isDone: true, sortPosition: 1, creationDate: .now)
        let sg23 = Subtask(id: "12", title: "Поговорить с носителем языка", isDone: false, sortPosition: 2, creationDate: .now)
        
        let g1 = Goal(id: "2", title: "Прочитать книги о Гарри Поттере", note: "", isDone: false, creationDate: .now)
        let sg11 = Subtask(id: "00", title: "Философский камень", isDone: true, sortPosition: 0, creationDate: .now)
        let sg12 = Subtask(id: "01", title: "Тайная комната", isDone: true, sortPosition: 1, creationDate: .now)
        let sg13 = Subtask(id: "02", title: "Узник Азкабана", isDone: false, sortPosition: 2, creationDate: .now)
        let sg14 = Subtask(id: "03", title: "Кубок огня", isDone: false, sortPosition: 3, creationDate: .now)
        let sg15 = Subtask(id: "04", title: "Орден феникса", isDone: false, sortPosition: 4, creationDate: .now)
        let sg16 = Subtask(id: "05", title: "Принц полукровка", isDone: false, sortPosition: 5, creationDate: .now)
        let sg17 = Subtask(id: "06", title: "Дары смерти", isDone: false, sortPosition: 6, creationDate: .now)
        
        let wc = WaterControl(neededVolume: 2300, drunkVolume: [Date.now.startOfDay: 1800], lastConfiguredSprintID: sprint.id, notificationsEnabled: true, notificationsInterval: 2, notificationsStartTime: .now, notificationsEndTime: .now)
        
        var counter = 19
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
        ServicesAssembly.shared.habitsService.addHabit(h3, sprintID: sprint.id, completion: c)
        ServicesAssembly.shared.habitsService.addHabit(h4, sprintID: sprint.id, completion: c)
        ServicesAssembly.shared.habitsService.addHabit(h2, sprintID: sprint.id, completion: c)
        ServicesAssembly.shared.habitsService.addHabit(h1, sprintID: sprint.id, completion: c)
        ServicesAssembly.shared.goalsService.addGoal(g1, sprintID: sprint.id, completion: c)
        ServicesAssembly.shared.goalsService.addGoal(g2, sprintID: sprint.id, completion: c)
        ServicesAssembly.shared.goalsService.addGoal(g3, sprintID: sprint.id, completion: c)
        ServicesAssembly.shared.subtasksService.addStage(sg11, to: g1, completion: c1)
        ServicesAssembly.shared.subtasksService.addStage(sg12, to: g1, completion: c1)
        ServicesAssembly.shared.subtasksService.addStage(sg13, to: g1, completion: c1)
        ServicesAssembly.shared.subtasksService.addStage(sg14, to: g1, completion: c1)
        ServicesAssembly.shared.subtasksService.addStage(sg15, to: g1, completion: c1)
        ServicesAssembly.shared.subtasksService.addStage(sg16, to: g1, completion: c1)
        ServicesAssembly.shared.subtasksService.addStage(sg17, to: g1, completion: c1)
        ServicesAssembly.shared.subtasksService.addStage(sg21, to: g2, completion: c1)
        ServicesAssembly.shared.subtasksService.addStage(sg22, to: g2, completion: c1)
        ServicesAssembly.shared.subtasksService.addStage(sg23, to: g2, completion: c1)
        ServicesAssembly.shared.waterControlService.createOrUpdateWaterControl(wc, completion: c1)
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
}

final class EnMocksConfigurator: MocksConfigurator {
    
    static func prepareMocks(completion: @escaping () -> Void) {
        let sprint = Sprint(id: "0", number: 1, title: "Sprint #1", startDate: Date().startOfDay - 7.asDays, endDate: Date() + 7.asWeeks, isReady: true, notifications: Sprint.Notifications())
        
        let dd1: [Date] = [.now, .now - 1.asDays, .now - 2.asDays, .now - 3.asDays, .now - 4.asDays, .now - 5.asDays, .now - 6.asDays]
        let dd2: [Date] = [.now, .now - 2.asDays, .now - 3.asDays, .now - 6.asDays, .now - 7.asDays]
        let dd3: [Date] = [.now - 1.asDays, .now - 2.asDays, .now - 3.asDays, .now - 4.asDays, .now - 5.asDays, .now - 7.asDays]
        let dueDays: [DayUnit] = [.monday, .friday, .saturday, .sunday, .thusday, .tuesday, .wednesday]
        var n1 = Date.now; n1 => 7.asHours; n1 => 30.asMinutes
        let h1 = Habit(id: "0", title: "Read news", note: "", link: "https://www.news.com", notificationDate: n1, repeatEndingDate: nil, dueDays: dueDays, doneDates: dd1, creationDate: .now)
        
        var n2 = Date.now; n2 => 7.asHours; n2 => 50.asMinutes
        let h2 = Habit(id: "1", title: "Do morning exercises", note: "", link: "", notificationDate: n2, repeatEndingDate: nil, dueDays: dueDays, doneDates: dd2, creationDate: .now)
        
        let h3 = Habit(id: "2", title: "Don't drink coffee", note: "", link: "", notificationDate: nil, repeatEndingDate: nil, dueDays: dueDays, doneDates: dd3, creationDate: .now)
        
        var n4 = Date.now; n4 => 20.asHours; n4 => 00.asMinutes
        let h4 = Habit(id: "3", title: "Learn Chinese 15 minutes", note: "", link: "", notificationDate: n4, repeatEndingDate: nil, dueDays: dueDays, doneDates: dd1, creationDate: .now)
        
        let g3 = Goal(id: "0", title: "Набрать 3 килограмма", note: "", isDone: false, creationDate: .now)
        
        let g2 = Goal(id: "1", title: "Повысить уровень английского", note: "", isDone: false, creationDate: .now)
        let sg21 = Subtask(id: "10", title: "Выучить 500 новых слов", isDone: false, sortPosition: 0, creationDate: .now)
        let sg22 = Subtask(id: "11", title: "Пройти курс разговорного английского", isDone: true, sortPosition: 1, creationDate: .now)
        let sg23 = Subtask(id: "12", title: "Поговорить с носителем языка", isDone: false, sortPosition: 2, creationDate: .now)
        
        let g1 = Goal(id: "2", title: "Read books about Harry Potter", note: "", isDone: false, creationDate: .now)
        let sg11 = Subtask(id: "00", title: "The Philisopher's stone", isDone: true, sortPosition: 0, creationDate: .now)
        let sg12 = Subtask(id: "01", title: "The Chamber of Secrets", isDone: true, sortPosition: 1, creationDate: .now)
        let sg13 = Subtask(id: "02", title: "The prisoner of Azkaban", isDone: false, sortPosition: 2, creationDate: .now)
        let sg14 = Subtask(id: "03", title: "The Goblet of Fire", isDone: false, sortPosition: 3, creationDate: .now)
        let sg15 = Subtask(id: "04", title: "The Order of the Phoenix", isDone: false, sortPosition: 4, creationDate: .now)
        let sg16 = Subtask(id: "05", title: "The Half-Blood Prince", isDone: false, sortPosition: 5, creationDate: .now)
        let sg17 = Subtask(id: "06", title: "The Deathly Hallows", isDone: false, sortPosition: 6, creationDate: .now)
        
        let wc = WaterControl(neededVolume: 2300, drunkVolume: [Date.now.startOfDay: 1800], lastConfiguredSprintID: sprint.id, notificationsEnabled: true, notificationsInterval: 2, notificationsStartTime: .now, notificationsEndTime: .now)
        
        var counter = 19
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
        ServicesAssembly.shared.habitsService.addHabit(h3, sprintID: sprint.id, completion: c)
        ServicesAssembly.shared.habitsService.addHabit(h4, sprintID: sprint.id, completion: c)
        ServicesAssembly.shared.habitsService.addHabit(h2, sprintID: sprint.id, completion: c)
        ServicesAssembly.shared.habitsService.addHabit(h1, sprintID: sprint.id, completion: c)
        ServicesAssembly.shared.goalsService.addGoal(g1, sprintID: sprint.id, completion: c)
        ServicesAssembly.shared.goalsService.addGoal(g2, sprintID: sprint.id, completion: c)
        ServicesAssembly.shared.goalsService.addGoal(g3, sprintID: sprint.id, completion: c)
        ServicesAssembly.shared.subtasksService.addStage(sg11, to: g1, completion: c1)
        ServicesAssembly.shared.subtasksService.addStage(sg12, to: g1, completion: c1)
        ServicesAssembly.shared.subtasksService.addStage(sg13, to: g1, completion: c1)
        ServicesAssembly.shared.subtasksService.addStage(sg14, to: g1, completion: c1)
        ServicesAssembly.shared.subtasksService.addStage(sg15, to: g1, completion: c1)
        ServicesAssembly.shared.subtasksService.addStage(sg16, to: g1, completion: c1)
        ServicesAssembly.shared.subtasksService.addStage(sg17, to: g1, completion: c1)
        ServicesAssembly.shared.subtasksService.addStage(sg21, to: g2, completion: c1)
        ServicesAssembly.shared.subtasksService.addStage(sg22, to: g2, completion: c1)
        ServicesAssembly.shared.subtasksService.addStage(sg23, to: g2, completion: c1)
        ServicesAssembly.shared.waterControlService.createOrUpdateWaterControl(wc, completion: c1)
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
}