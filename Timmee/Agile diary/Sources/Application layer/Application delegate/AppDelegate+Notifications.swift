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

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let endDate = notification.request.content.userInfo["end_date"] as? Date {
            if endDate <= Date.now {
                center.removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
                center.removePendingNotificationRequests(withIdentifiers: [notification.request.identifier])
            }
        }
        
        if notification.request.content.categoryIdentifier == NotificationCategories.task.rawValue {
            if let taskID = notification.request.content.userInfo["task_id"] as? String {
                updateDueDateAndNotificationDate(ofTaskWithID: taskID)
            }
            
            completionHandler([.alert, .sound])
        } else if notification.request.content.categoryIdentifier == NotificationCategories.waterControl.rawValue {
            completionHandler([.alert, .sound])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if let endDate = response.notification.request.content.userInfo["end_date"] as? Date {
            if endDate <= Date.now {
                center.removeDeliveredNotifications(withIdentifiers: [response.notification.request.identifier])
                center.removePendingNotificationRequests(withIdentifiers: [response.notification.request.identifier])
            }
        }
        
        if response.notification.request.content.categoryIdentifier == NotificationCategories.task.rawValue {
            guard let taskID = response.notification.request.content.userInfo["task_id"] as? String else {
                completionHandler()
                return
            }
            
            handleTaskAction(withIdentifier: response.actionIdentifier,
                             taskID: taskID,
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
    
    func handleTaskAction(withIdentifier identifier: String, taskID: String, fireDate: Date?, completion: @escaping () -> Void) {
        if let action = NotificationAction(rawValue: identifier) {
            switch action {
            case .done:
                guard let task = ServicesAssembly.shared.tasksService.fetchTask(id: taskID) else { completion(); return }
                let doneDate = fireDate?.startOfDay ?? Date.now.startOfDay
                guard !task.doneDates.contains(doneDate) else { completion(); return }
                task.doneDates.append(doneDate)
                ServicesAssembly.shared.tasksService.updateTask(task) { _ in
                    completion()
                }
            case .remindAfter(let minutes):
                deferNotification(ofTaskWithID: taskID, by: minutes, fireDate: fireDate, completion: completion)
            default: completion()
            }
        } else {
            completion()
        }
    }
    
    func handleWaterControlAction(withIdentifier identifier: String, fireDate: Date, completion: @escaping () -> Void) {
        if let action = NotificationAction(rawValue: identifier) {
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
    
    func updateDueDateAndNotificationDate(ofTaskWithID id: String) {
        guard let task = ServicesAssembly.shared.tasksService.fetchTask(id: id) else { return }
        task.dueDate = task.nextDueDate
        task.notificationDate = task.nextNotificationDate
        ServicesAssembly.shared.tasksService.updateTask(task, completion: { _ in })
    }
    
    func deferNotification(ofTaskWithID id: String, by minutes: Int, fireDate: Date?, completion: @escaping () -> Void) {
        guard let task = ServicesAssembly.shared.tasksService.fetchTask(id: id) else {
            completion()
            return
        }
        guard let oldFireDate = fireDate else {
            completion()
            return
        }
        
        let nextFireDate = oldFireDate + minutes.asMinutes
        
        TaskSchedulerService().scheduleDeferredTask(task, fireDate: nextFireDate)
        completion()
    }
    
}
