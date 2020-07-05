//
//  IntentHandler.swift
//  Agilee diary Siri Intent
//
//  Created by Илья Харабет on 04.07.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Intents
import TasksKit

class IntentHandler: INExtension, TodayHabitsIntentIntentHandling, SprintInteractorTrait {
    
    let sprintsService = ServicesAssembly.shared.sprintsService
    let habitsService = ServicesAssembly.shared.habitsService
    
    override func handler(for intent: INIntent) -> Any {
        return self
    }
    
    func handle(intent: TodayHabitsIntentIntent, completion: @escaping (TodayHabitsIntentIntentResponse) -> Void) {
        guard let currentSprint = getCurrentSprint() else {
            return completion(.init(code: .failure, userActivity: nil))
        }
        
        let habits = habitsService.fetchHabits(
            sprintID: currentSprint.id,
            day: DayUnit.init(weekday: Date.now.weekday),
            date: Date.now
        )
        
        if habits.isEmpty {
            completion(.init(code: .noHabits, userActivity: nil))
        } else {
            let response = TodayHabitsIntentIntentResponse(code: .success, userActivity: nil)
            response.habitsCount = NSNumber(value: habits.count)
            completion(response)
        }
    }
    
    func confirm(intent: TodayHabitsIntentIntent, completion: @escaping (TodayHabitsIntentIntentResponse) -> Void) {
        handle(intent: intent, completion: completion)
    }
    
}
