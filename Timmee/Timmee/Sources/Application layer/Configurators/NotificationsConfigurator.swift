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
    
    static func getNotificationsPermissionStatus(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    completion(settings.authorizationStatus == .authorized)
                }
            }
        }
    }
    
    static func registerForLocalNotifications(application: UIApplication, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().delegate = application.delegate as? UNUserNotificationCenterDelegate
            UNUserNotificationCenter.current().setNotificationCategories(makeLocalNotificationsCategories())
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { isAuthorized, _ in
                DispatchQueue.main.async {
                    completion(isAuthorized)
                }
            }
        }
    }
    
    static func updateNotificationCategoriesIfPossible() {
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized else { return }
                UNUserNotificationCenter.current().setNotificationCategories(makeLocalNotificationsCategories())
            }
        }
    }
    
    static func removeAppIconBadge() {
        UIApplication.shared.applicationIconBadgeNumber = -1
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
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
    
    private static func makeDoneAction() -> UNNotificationAction {
        return UNNotificationAction(identifier: NotificationAction.done.rawValue,
                                    title: "complete".localized,
                                    options: [])
    }
    
    private static func makeRemindLaterAction(minutes: Int) -> UNNotificationAction {
        return UNNotificationAction(identifier: NotificationAction.remindAfter(minutes).rawValue,
                                    title: NotificationAction.remindAfter(minutes).rawValue.localized,
                                    options: [])
    }
    
}
