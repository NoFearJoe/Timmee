//
//  AppDelegate+Notifications.swift
//  Timmee
//
//  Created by Ilya Kharabet on 12.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date
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
        if notification.request.content.categoryIdentifier == NotificationCategories.task.rawValue {
//            if let taskID = notification.request.content.userInfo["task_id"] as? String {
//                updateDueDateAndNotificationDate(ofTaskWithID: taskID)
//            }
            
            if let endDate = notification.request.content.userInfo["end_date"] as? Date {
                if endDate <= Date() {
                    center.removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
                    center.removePendingNotificationRequests(withIdentifiers: [notification.request.identifier])
                }
            }
            
            completionHandler([.alert, .sound])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.content.categoryIdentifier == NotificationCategories.task.rawValue {
            if let endDate = response.notification.request.content.userInfo["end_date"] as? Date {
                if endDate <= Date() {
                    center.removeDeliveredNotifications(withIdentifiers: [response.notification.request.identifier])
                    center.removePendingNotificationRequests(withIdentifiers: [response.notification.request.identifier])
                }
            }
            
            guard let taskID = response.notification.request.content.userInfo["task_id"] as? String else {
                completionHandler()
                return
            }
            
            handleTaskAction(withIdentifier: response.actionIdentifier,
                             taskID: taskID,
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
                ServicesAssembly.shared.tasksService.completeTask(withID: taskID, doneDate: fireDate ?? Date(), completion: completion)
            case .remindAfter(let minutes):
                deferNotification(ofTaskWithID: taskID, by: minutes, fireDate: fireDate, completion: completion)
            }
        } else {
            completion()
        }
    }
    
}

private extension AppDelegate {
    
    func updateDueDateAndNotificationDate(ofTaskWithID id: String) {
        guard let task = ServicesAssembly.shared.tasksService.fetchTask(id: id) else { return }
        guard task.kind == .regular || task.repeating.type != .never else { return }
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
