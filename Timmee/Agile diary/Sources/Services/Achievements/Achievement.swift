//
//  Achievement.swift
//  Agile diary
//
//  Created by Илья Харабет on 31/05/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

enum Achievement: String, CaseIterable {
    
    // MARK: - Habits
    
    // Первый раз выполнил все привычки за день.
    case doneAllHabitsInADayFirstTime
    
    // Выполнил привычку на 25% за спринт.
    case doneHabit25Percent
    
    // Выполнил привычку на 50% за спринт.
    case doneHabit50Percent
    
    // Выполнил привычку на 75% за спринт.
    case doneHabit75Percent
    
    // Выполнил все привычки в спринте.
    case doneHabit100Percent
    
    // Выполнил привычку 5 раз подряд.
    case doneHabit5TimesInARow
    
    // Выполнил привычку 10 раз подряд.
    case doneHabit10TimesInARow
    
    // Выполнил привычку 25 раз подряд.
    case doneHabit25TimesInARow
    
    // Выполнил привычку 50 раз подряд.
    case doneHabit50TimesInARow
    
    // MARK: - Goals
    
    // Достиг первую цель в спринте.
    case doneFirstGoal
    
    // Достиг всех целей в спринте.
    case doneAllGoals
    
    // MARK: - Other
    
    // Выполнил все привычки и достиг всех целей в спринте.
    case doneAllTasksInASprint
    
    // Закончил первый спринт
    case doneFirstSprint
    
}

extension Achievement {
    
    var title: String {
        switch self {
        case .doneAllHabitsInADayFirstTime:
            return "achievement_done_all_habits_in_a_day_first_time".localized
        case .doneHabit25Percent:
            return "achievement_done_habit_25_percent".localized
        case .doneHabit50Percent:
            return "achievement_done_habit_50_percent".localized
        case .doneHabit75Percent:
            return "achievement_done_habit_75_percent".localized
        case .doneHabit100Percent:
            return "achievement_done_habit_100_percent".localized
        case .doneHabit5TimesInARow:
            return "achievement_done_habit_5_times_in_a_row".localized
        case .doneHabit10TimesInARow:
            return "achievement_done_habit_10_times_in_a_row".localized
        case .doneHabit25TimesInARow:
            return "achievement_done_habit_25_times_in_a_row".localized
        case .doneHabit50TimesInARow:
            return "achievement_done_habit_50_times_in_a_row".localized
            
        case .doneFirstGoal:
            return "achievement_done_first_goal".localized
        case .doneAllGoals:
            return "achievement_done_all_goals".localized
            
        case .doneAllTasksInASprint:
            return "achievement_done_all_tasks_in_a_sprint".localized
        case .doneFirstSprint:
            return "achievement_done_first_sprint".localized
        }
    }
    
    var icon: UIImage {
        let name: String = {
            switch self {
            case .doneAllHabitsInADayFirstTime:
                return "achievement_habit"
            case .doneHabit25Percent:
                return "achievement_habit"
            case .doneHabit50Percent:
                return "achievement_habit"
            case .doneHabit75Percent:
                return "achievement_habit"
            case .doneHabit100Percent:
                return "achievement_habit"
            case .doneHabit5TimesInARow:
                return "achievement_habit_row"
            case .doneHabit10TimesInARow:
                return "achievement_habit_row"
            case .doneHabit25TimesInARow:
                return "achievement_habit_row"
            case .doneHabit50TimesInARow:
                return "achievement_habit_row"
                
            case .doneFirstGoal:
                return "achievement_goal"
            case .doneAllGoals:
                return "achievement_goal"
                
            case .doneAllTasksInASprint:
                return "achievement_sprint"
            case .doneFirstSprint:
                return "achievement_sprint"
            }
        }()
        
        return UIImage(named: name) ?? UIImage()
    }
    
}
