//
//  AppDelegate+Notifications.swift
//  Agile diary
//
//  Created by Илья Харабет on 15.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import struct Foundation.Date
import class UIKit.UIApplication
import class UserNotifications.UNNotification
import class UserNotifications.UNNotificationResponse
import class UserNotifications.UNUserNotificationCenter
import struct UserNotifications.UNNotificationPresentationOptions
import protocol UserNotifications.UNUserNotificationCenterDelegate
import var UserNotifications.UNNotificationDefaultActionIdentifier
import class UserNotifications.UNCalendarNotificationTrigger

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let endDate = notification.request.content.userInfo["end_date"] as? Date {
            let nextTriggerDate = (notification.request.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate()
            if endDate <= Date.now || endDate <= (nextTriggerDate ?? Date.now) {
                center.removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
                center.removePendingNotificationRequests(withIdentifiers: [notification.request.identifier])
            }
        }
        
        if notification.request.content.categoryIdentifier == NotificationCategories.habit.rawValue {
            completionHandler([.alert, .sound])
        } else if notification.request.content.categoryIdentifier == NotificationCategories.waterControl.rawValue {
            completionHandler([.alert, .sound])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if let endDate = response.notification.request.content.userInfo["end_date"] as? Date {
            let nextTriggerDate = (response.notification.request.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate()
            if endDate <= Date.now || endDate <= (nextTriggerDate ?? Date.now) {
                center.removeDeliveredNotifications(withIdentifiers: [response.notification.request.identifier])
                center.removePendingNotificationRequests(withIdentifiers: [response.notification.request.identifier])
            }
        }
        
        if response.notification.request.content.categoryIdentifier == NotificationCategories.habit.rawValue {
            guard let habitID = response.notification.request.content.userInfo["habit_id"] as? String else {
                completionHandler()
                return
            }
            
            handleHabitAction(withIdentifier: response.actionIdentifier,
                              habitID: habitID,
                              fireDate: response.notification.date,
                              completion: completionHandler)
        } else if response.notification.request.content.categoryIdentifier == NotificationCategories.waterControl.rawValue {
            handleWaterControlAction(withIdentifier: response.actionIdentifier,
                                     fireDate: response.notification.date,
                                     completion: completionHandler)
        }
    }
    
}

private extension AppDelegate {
    
    func handleHabitAction(withIdentifier identifier: String, habitID: String, fireDate: Date, completion: @escaping () -> Void) {
        if let action = NotificationAction(rawValue: identifier), fireDate.isWithinSameDay(of: .now) {
            switch action {
            case .done:
                guard let habit = ServicesAssembly.shared.habitsService.fetchHabit(id: habitID) else { completion(); return }
                let doneDate = fireDate.startOfDay
                guard !habit.doneDates.contains(doneDate) else { completion(); return }
                habit.doneDates.append(doneDate)
                ServicesAssembly.shared.habitsService.updateHabit(habit) { _ in
                    completion()
                }
            case .remindAfter(let minutes):
                deferNotification(ofHabitWithID: habitID, by: minutes, fireDate: fireDate, completion: completion)
            default: completion()
            }
        } else {
            completion()
        }
    }
    
    func handleWaterControlAction(withIdentifier identifier: String, fireDate: Date, completion: @escaping () -> Void) {
        if let action = NotificationAction(rawValue: identifier), fireDate.isWithinSameDay(of: .now) {
            switch action {
            case let .drunkWater(milliliters):
                guard let waterControl = ServicesAssembly.shared.waterControlService.fetchWaterControl() else { completion(); return }
                if let todayDrunk = waterControl.drunkVolume[fireDate.startOfDay] {
                    waterControl.drunkVolume[fireDate.startOfDay] = todayDrunk + milliliters
                } else {
                    waterControl.drunkVolume[fireDate.startOfDay] = milliliters
                }
                ServicesAssembly.shared.waterControlService.createOrUpdateWaterControl(waterControl, completion: completion)
            default: completion()
            }
        } else {
            completion()
        }
    }
    
}

private extension AppDelegate {
    
    func deferNotification(ofHabitWithID id: String, by minutes: Int, fireDate: Date?, completion: @escaping () -> Void) {
        guard let habit = ServicesAssembly.shared.habitsService.fetchHabit(id: id) else {
            completion()
            return
        }
        guard let oldFireDate = fireDate else {
            completion()
            return
        }
        
        let nextFireDate = oldFireDate + minutes.asMinutes
        
        HabitsSchedulerService().scheduleDeferredHabit(habit, fireDate: nextFireDate)
        
        completion()
    }
    
}
