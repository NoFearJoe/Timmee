//
//  HabitCreationInteractor.swift
//  Agile diary
//
//  Created by i.kharabet on 15.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

final class HabitCreationInteractor {}

extension HabitCreationInteractor {
    
    func createHabit() -> Habit {
        return Habit(habitID: RandomStringGenerator.randomString(length: 24))
    }
    
}
