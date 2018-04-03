//
//  AppDelegate+Notifications.swift
//  Timmee
//
//  Created by Ilya Kharabet on 12.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date
import class UIKit.UIApplication
import class UIKit.UILocalNotification
import class UIKit.UIUserNotificationSettings
import class UserNotifications.UNNotification
import class UserNotifications.UNNotificationResponse
import class UserNotifications.UNUserNotificationCenter
import struct UserNotifications.UNNotificationPresentationOptions
import protocol UserNotifications.UNUserNotificationCenterDelegate
import var UserNotifications.UNNotificationDefaultActionIdentifier

extension AppDelegate {
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        if notification.category == NotificationCategories.task.rawValue {
            if let taskID = notification.userInfo?["task_id"] as? String {
                updateDueDate(ofTaskWithID: taskID)
            }
            
            if let endDate = notification.userInfo?["end_date"] as? Date {
                if endDate <= Date() {
                    application.cancelLocalNotification(notification)
                }
            }
        }
    }

    func application(_ application: UIApplication,
                     handleActionWithIdentifier identifier: String?,
                     for notification: UILocalNotification,
                     withResponseInfo responseInfo: [AnyHashable : Any],
                     completionHandler: @escaping () -> Void) {
        guard let identifier = identifier else {
            completionHandler()
            return
        }
        
        if notification.category == NotificationCategories.task.rawValue {
            guard let taskID = notification.userInfo?["task_id"] as? String else {
                completionHandler()
                return
            }
            
            handleTaskAction(withIdentifier: identifier,
                             taskID: taskID,
                             fireDate: notification.fireDate,
                             completion: completionHandler)
        } else {
            completionHandler()
        }
    }

    func application(_ application: UIApplication,
                     handleActionWithIdentifier identifier: String?,
                     for notification: UILocalNotification,
                     completionHandler: @escaping () -> Void) {
        guard let identifier = identifier else {
            completionHandler()
            return
        }
        
        if notification.category == NotificationCategories.task.rawValue {
            guard let taskID = notification.userInfo?["task_id"] as? String else {
                completionHandler()
                return
            }
            
            handleTaskAction(withIdentifier: identifier,
                             taskID: taskID,
                             fireDate: notification.fireDate,
                             completion: completionHandler)
        } else {
            completionHandler()
        }
    }

}

@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if notification.request.content.categoryIdentifier == NotificationCategories.task.rawValue {
            if let taskID = notification.request.content.userInfo["task_id"] as? String {
                updateDueDate(ofTaskWithID: taskID)
            }
            
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
                TasksService().doneTask(withID: taskID, completion: {
                    completion()
                })
            case .remindAfter(let minutes):
                deferNotification(ofTaskWithID: taskID, by: minutes, fireDate: fireDate, completion: completion)
            }
        } else {
            completion()
        }
    }
    
}

private extension AppDelegate {
    
    func updateDueDate(ofTaskWithID id: String) {
        guard let task = TasksService().retrieveTask(withID: id) else { return }
        task.dueDate = task.nextDueDate
        TasksService().updateTask(task, completion: { _ in })
    }
    
    func deferNotification(ofTaskWithID id: String, by minutes: Int, fireDate: Date?, completion: @escaping () -> Void) {
        guard let task = TasksService().retrieveTask(withID: id) else {
            completion()
            return
        }
        guard let oldFireDate = fireDate else {
            completion()
            return
        }
        
        let nextFireDate = oldFireDate + minutes.asMinutes

        let title = TasksService().retrieveList(of: task)?.title
        TaskSchedulerService().scheduleDeferredTask(task, listTitle: title ?? "all_tasks".localized, fireDate: nextFireDate)
        completion()
    }
    
}
