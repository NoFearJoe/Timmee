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

enum NotificationAction {
    case done // Закончить задачу
    case remindAfter(Int) // Напомнить позже
    
    init?(rawValue: String) {
        if rawValue == "done" {
            self = .done
        } else if rawValue.starts(with: "remind_after") {
            let minutes = Int(String(rawValue[rawValue.index(rawValue.startIndex, offsetBy: 13)...])) ?? 0
            self = .remindAfter(minutes)
        } else {
            return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .done: return "done"
        case .remindAfter(let minutes): return "remind_after_\(minutes)"
        }
    }
    
}

// MARK: - Notification configurator

final class NotificationsConfigurator {
    
    static func registerForLocalNotifications(application: UIApplication) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = application.delegate as? UNUserNotificationCenterDelegate
            UNUserNotificationCenter.current().setNotificationCategories(makeLocalNotificationsCategories())
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { _,_  in }
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound],
                                                      categories: makeLocalNotificationsCategories())
            application.registerUserNotificationSettings(settings)
        }
    }
    
    static func updateNotificationCategoriesIfPossible(application: UIApplication) {
        guard let settings = application.currentUserNotificationSettings, !settings.types.isEmpty else { return }
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().setNotificationCategories(makeLocalNotificationsCategories())
        } else {
            let settings = UIUserNotificationSettings(types: settings.types,
                                                      categories: makeLocalNotificationsCategories())
            application.registerUserNotificationSettings(settings)
        }
    }
    
    private static func makeLocalNotificationsCategories() -> Set<UIUserNotificationCategory> {
        let taskCategory = UIMutableUserNotificationCategory()
        taskCategory.identifier = NotificationCategories.task.rawValue
        taskCategory.setActions([makeDoneAction(),
                                 makeRemindLaterAction(minutes: 10),
                                 makeRemindLaterAction(minutes: 30),
                                 makeRemindLaterAction(minutes: 60)],
                                for: .default)
        
        return Set(arrayLiteral: taskCategory)
    }
    
    @available(iOS 10.0, *)
    private static func makeLocalNotificationsCategories() -> Set<UNNotificationCategory> {
        let taskCategory = UNNotificationCategory(identifier: NotificationCategories.task.rawValue,
                                                  actions: [makeDoneAction(),
                                                            makeRemindLaterAction(minutes: 10),
                                                            makeRemindLaterAction(minutes: 30),
                                                            makeRemindLaterAction(minutes: 60)],
                                                  intentIdentifiers: [],
                                                  options: [])
        
        return Set(arrayLiteral: taskCategory)
    }
    
    private static func makeDoneAction() -> UIUserNotificationAction {
        let doneAction = UIMutableUserNotificationAction()
        doneAction.identifier = NotificationAction.done.rawValue
        doneAction.title = "complete".localized
        doneAction.activationMode = .background
        doneAction.behavior = .default
        doneAction.isAuthenticationRequired = false
        doneAction.isDestructive = false
        
        return doneAction
    }
    
    @available(iOS 10.0, *)
    private static func makeDoneAction() -> UNNotificationAction {
        return UNNotificationAction(identifier: NotificationAction.done.rawValue,
                                    title: "complete".localized,
                                    options: [])
    }
    
    private static func makeRemindLaterAction(minutes: Int) -> UIUserNotificationAction {
        let remindLaterAction = UIMutableUserNotificationAction()
        remindLaterAction.identifier = NotificationAction.remindAfter(minutes).rawValue
        remindLaterAction.title = NotificationAction.remindAfter(minutes).rawValue.localized
        remindLaterAction.activationMode = .background
        remindLaterAction.behavior = .default
        remindLaterAction.isAuthenticationRequired = false
        remindLaterAction.isDestructive = false
        
        return remindLaterAction
    }
    
    @available(iOS 10.0, *)
    private static func makeRemindLaterAction(minutes: Int) -> UNNotificationAction {
        return UNNotificationAction(identifier: NotificationAction.remindAfter(minutes).rawValue,
                                    title: NotificationAction.remindAfter(minutes).rawValue.localized,
                                    options: [])
    }
    
}
