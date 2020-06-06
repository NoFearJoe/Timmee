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
    
    public static let shared = HabitsSchedulerService()
    
    public func scheduleHabit(_ habit: Habit) {
        removeNotifications(for: habit) {
            self.scheduleNewHabit(habit)
        }
    }
    
    private func scheduleNewHabit(_ habit: Habit) {
        guard !habit.notificationsTime.isEmpty else { return }
        guard let endDate = habit.repeatEndingDate else { return }
        
        let now = Date()
        var notificationDate = Date()
        
        while notificationDate <= endDate {
            guard notificationDate >= now else {
                notificationDate = notificationDate + 1.asDays
                continue
            }
            guard (habit.dueDays.map { $0.weekday }).contains(notificationDate.weekday) else {
                notificationDate = notificationDate + 1.asDays
                continue
            }
            
            habit.notificationsTime.forEach { time in
                var fireDate = notificationDate.startOfMinute
                fireDate => time.hours.asHours
                fireDate => time.minutes.asMinutes
                
                let userInfo = HabitsSchedulerService.makeUserInfo(
                    habitID: habit.id,
                    isDeferred: false,
                    endDate: habit.repeatEndingDate
                )
                
                debugPrint("::: Habit notification registered at \(fireDate)")
                
                scheduleLocalNotification(
                    withID: habit.id + "\(fireDate.timeIntervalSince1970)",
                    title: habit.title,
                    message: HabitsSchedulerService.makeNotificationMessage(for: habit),
                    at: fireDate,
                    repeatUnit: nil,
                    category: "habit",
                    userInfo: userInfo
                )
            }
            
            notificationDate = notificationDate + 1.asDays
        }
    }
    
    /**
     Создает уведомление для задачи, которую пользователь перенес на другое время
     */
    public func scheduleDeferredHabit(_ habit: Habit, fireDate: Date) {
        removeDeferredNotifications(for: habit) {
            self.scheduleNewDeferredHabit(habit, fireDate: fireDate)
        }
    }
    
    private func scheduleNewDeferredHabit(_ habit: Habit, fireDate: Date) {
        let userInfo = HabitsSchedulerService.makeUserInfo(habitID: habit.id, isDeferred: true, endDate: habit.repeatEndingDate)
        scheduleLocalNotification(withID: habit.id + "\(fireDate.weekday)",
                                  title: habit.title,
                                  message: HabitsSchedulerService.makeNotificationMessage(for: habit),
                                  at: fireDate,
                                  repeatUnit: nil,
                                  category: "habit",
                                  userInfo: userInfo)
    }
    
    public func removeNotifications(for habit: Habit, completion: @escaping () -> Void) {
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
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
//    public func removeTodaysNotification(for habit: Habit) {
//        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
//            let identifier = requests.first(where: { request in
//                if let habitID = request.content.userInfo["habit_id"] as? String,
//                   let trigger = request.trigger as? UNCalendarNotificationTrigger,
//                   let nextTriggerDate = trigger.nextTriggerDate(),
//                   nextTriggerDate.isWithinSameDay(of: Date()) {
//                    return habitID == habit.id
//                }
//                return false
//            })?.identifier
//            
//            guard let id = identifier else { return }
//            
//            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
//        }
//    }
    
    public func removeDeferredNotifications(for habit: Habit, completion: @escaping () -> Void) {
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
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
}

private extension HabitsSchedulerService {
    
    static func makeNotificationMessage(for habit: Habit) -> String {
        if let value = habit.value {
            return value.localized
        } else if !habit.link.isEmpty {
            return habit.link
        } else {
            return habit.note
        }
    }
    
    static func makeUserInfo(habitID: String, isDeferred: Bool, endDate: Date?) -> [String: Any] {
        var userInfo = ["habit_id": habitID, "isDeferred": isDeferred] as [String : Any]
        if let endDate = endDate {
            userInfo["end_date"] = endDate
        }
        return userInfo
    }
    
}
