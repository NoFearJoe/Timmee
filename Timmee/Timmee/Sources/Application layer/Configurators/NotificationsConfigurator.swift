//
//  NotificationsConfigurator.swift
//  Timmee
//
//  Created by Ilya Kharabet on 12.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import Foundation
import class UIKit.UIApplication
import class UIKit.UIUserNotificationAction
import class UIKit.UIMutableUserNotificationAction
import class UIKit.UIUserNotificationSettings
import class UIKit.UIUserNotificationCategory
import class UIKit.UIMutableUserNotificationCategory
import struct UIKit.UIUserNotificationType
import enum UIKit.UIUserNotificationActionContext
import class UserNotifications.UNUserNotificationCenter
import class UserNotifications.UNNotificationAction
import class UserNotifications.UNNotificationCategory
import struct UserNotifications.UNNotificationCategoryOptions
import protocol UserNotifications.UNUserNotificationCenterDelegate

// MARK: - Notification categories

enum NotificationCategories: String {
    case task
}

enum NotificationActions: String {
    case done
}

// MARK: - Notification configurator

final class NotificationsConfigurator {
    
    static func registerForLocalNotifications(application: UIApplication) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = application.delegate as? UNUserNotificationCenterDelegate
            UNUserNotificationCenter.current().setNotificationCategories(makeLocalNotificationsCategories())
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { _ in }
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound],
                                                      categories: makeLocalNotificationsCategories())
            application.registerUserNotificationSettings(settings)
        }
    }
    
    private static func makeLocalNotificationsCategories() -> Set<UIUserNotificationCategory> {
        let taskCategory = UIMutableUserNotificationCategory()
        taskCategory.identifier = NotificationCategories.task.rawValue
        taskCategory.setActions([makeDoneAction()], for: .default)
        
        return Set(arrayLiteral: taskCategory)
    }
    
    @available(iOS 10.0, *)
    private static func makeLocalNotificationsCategories() -> Set<UNNotificationCategory> {
        let taskCategory = UNNotificationCategory(identifier: NotificationCategories.task.rawValue,
                                                  actions: [makeDoneAction()],
                                                  intentIdentifiers: [],
                                                  options: [])
        
        return Set(arrayLiteral: taskCategory)
    }
    
    private static func makeDoneAction() -> UIUserNotificationAction {
        let doneAction = UIMutableUserNotificationAction()
        doneAction.identifier = NotificationActions.done.rawValue
        doneAction.title = "done".localized
        doneAction.activationMode = .background
        doneAction.behavior = .default
        doneAction.isAuthenticationRequired = false
        doneAction.isDestructive = false
        
        return doneAction
    }
    
    @available(iOS 10.0, *)
    private static func makeDoneAction() -> UNNotificationAction {
        return UNNotificationAction(identifier: NotificationActions.done.rawValue,
                                    title: "done".localized,
                                    options: [])
    }
    
    // TODO: Доработать и добавить в список
    private static func makeRemindLaterAction() -> UIUserNotificationAction {
        let remindLaterAction = UIMutableUserNotificationAction()
        remindLaterAction.identifier = "remind_later"
        remindLaterAction.title = "remind_later".localized
        remindLaterAction.activationMode = .background
        remindLaterAction.behavior = .default
        remindLaterAction.isAuthenticationRequired = false
        remindLaterAction.isDestructive = false
        
        return remindLaterAction
    }
    
}
