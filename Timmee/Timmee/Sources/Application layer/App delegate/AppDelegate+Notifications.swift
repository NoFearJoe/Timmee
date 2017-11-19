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
            if identifier == NotificationActions.done.rawValue {
                guard let taskID = notification.userInfo?["task_id"] as? String else {
                    completionHandler()
                    return
                }
                TasksService().doneTask(withID: taskID, completion: {
                    completionHandler()
                })
            } else {
                completionHandler()
            }
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
            if identifier == NotificationActions.done.rawValue {
                guard let taskID = notification.userInfo?["task_id"] as? String else {
                    completionHandler()
                    return
                }
                TasksService().doneTask(withID: taskID, completion: {
                    completionHandler()
                })
            } else {
                completionHandler()
            }
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
            
            if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
                completionHandler()
            } else if response.actionIdentifier == NotificationActions.done.rawValue {
                guard let taskID = response.notification.request.content.userInfo["task_id"] as? String else {
                    completionHandler()
                    return
                }
                TasksService().doneTask(withID: taskID, completion: {
                    completionHandler()
                })
            }
        }
    }
    
}
