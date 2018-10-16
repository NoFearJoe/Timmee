//
//  HabitsSchedulerService.swift
//  NotificationsKit
//
//  Created by Илья Харабет on 16/10/2018.
//  Copyright © 2018 Илья Харабет. All rights reserved.
//

import Workset
import TasksKit
import UserNotifications

public final class HabitsSchedulerService: BaseSchedulerService {
    
    public func scheduleHabit(_ habit: Habit) {
        removeNotifications(for: habit)
        
        guard let notificationDate = habit.notificationDate else { return }
        
        (0..<7).forEach { day in
            let fireDate = notificationDate + day.asDays
            
            guard !(fireDate <= Date()) else { return }
            
            let dayNumber = fireDate.weekday - 1
            guard (habit.dueDays.map { $0.number }).contains(dayNumber) else { return }
            
            let userInfo = HabitsSchedulerService.makeUserInfo(habitID: habit.id, isDeferred: false, endDate: habit.repeatEndingDate)
            scheduleLocalNotification(withID: habit.id,
                                      title: habit.title,
                                      message: HabitsSchedulerService.makeNotificationMessage(for: habit),
                                      at: fireDate,
                                      repeatUnit: .weekOfYear,
                                      category: "habit",
                                      userInfo: userInfo)
        }
    }
    
    /**
     Создает уведомление для задачи, которую пользователь перенес на другое время
     */
    public func scheduleDeferredHabit(_ habit: Habit, fireDate: Date) {
        removeDeferredNotifications(for: habit)
                
        let userInfo = HabitsSchedulerService.makeUserInfo(habitID: habit.id, isDeferred: true, endDate: habit.repeatEndingDate)
        scheduleLocalNotification(withID: habit.id,
                                  title: habit.title,
                                  message: HabitsSchedulerService.makeNotificationMessage(for: habit),
                                  at: fireDate,
                                  repeatUnit: nil,
                                  category: "habit",
                                  userInfo: userInfo)
    }
    
    public func removeNotifications(for habit: Habit) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiers = requests.filter { request in
                    if let habitID = request.content.userInfo["habit_id"] as? String {
                        return habitID == habit.id
                    }
                    return false
                }.map { request in
                    request.identifier
                }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
    public func removeDeferredNotifications(for habit: Habit) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiers = requests.filter { request in
                    if let habitID = request.content.userInfo["habit_id"] as? String, let isDeferred = request.content.userInfo["isDeferred"] as? Bool {
                        return habitID == habit.id && isDeferred
                    }
                    return false
                }.map { request in
                    request.identifier
                }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
}

private extension HabitsSchedulerService {
    
    static func makeNotificationMessage(for habit: Habit) -> String {
        if let notificationDate = habit.notificationDate {
            return notificationDate.asNearestDateString
        }
        return habit.note
    }
    
    static func makeUserInfo(habitID: String, isDeferred: Bool, endDate: Date?) -> [String: Any] {
        var userInfo = ["habit_id": habitID, "isDeferred": isDeferred] as [String : Any]
        if let endDate = endDate {
            userInfo["end_date"] = endDate
        }
        return userInfo
    }
    
}
