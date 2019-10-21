//
//  NotificationsConfigurator.swift
//  Agile diary
//
//  Created by Илья Харабет on 15.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
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
    case habit
    case waterControl = "water_control"
}

enum NotificationAction {
    case done // Закончить задачу
    case remindAfter(Int) // Напомнить позже
    case drunkWater(Int) // Выпил воды (в миллилитрах)
    
    init?(rawValue: String) {
        if rawValue == "done" {
            self = .done
        } else if rawValue.starts(with: "remind_after") {
            let minutes = Int(String(rawValue[rawValue.index(rawValue.startIndex, offsetBy: 13)...])) ?? 0
            self = .remindAfter(minutes)
        } else if rawValue.starts(with: "drunk_water") {
            let milliliters = Int(String(rawValue[rawValue.index(rawValue.startIndex, offsetBy: 12)...])) ?? 0
            self = .drunkWater(milliliters)
        } else {
            return nil
        }
    }
    
    var rawValue: String {
        switch self {
        case .done: return "done"
        case let .remindAfter(minutes): return "remind_after_\(minutes)"
        case let .drunkWater(milliliters): return "drunk_water_\(milliliters)"
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
            UNUserNotificationCenter.current().setNotificationCategories(makeLocalNotificationsCategories())
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { isAuthorized, _ in
                DispatchQueue.main.async {
                    completion(isAuthorized)
                }
            }
        }
    }
    
    static func updateNotificationCategoriesIfPossible(application: UIApplication) {
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().setNotificationCategories(makeLocalNotificationsCategories())
        }
    }
    
    static func removeAppIconBadge() {
        UIApplication.shared.applicationIconBadgeNumber = -1
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    private static func makeLocalNotificationsCategories() -> Set<UNNotificationCategory> {
        let habitCategory = UNNotificationCategory(identifier: NotificationCategories.habit.rawValue,
                                                   actions: [makeDoneAction(),
                                                             makeRemindLaterAction(minutes: 10),
                                                             makeRemindLaterAction(minutes: 30),
                                                             makeRemindLaterAction(minutes: 60)],
                                                   intentIdentifiers: [],
                                                   options: [])
        let waterControlCategory = UNNotificationCategory(identifier: NotificationCategories.waterControl.rawValue,
                                                          actions: [makeDrunkWaterAction(milliliters: 100),
                                                                    makeDrunkWaterAction(milliliters: 200),
                                                                    makeDrunkWaterAction(milliliters: 300)],
                                                          intentIdentifiers: [],
                                                          options: [])
        
        return Set([habitCategory, waterControlCategory])
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
    
    private static func makeDrunkWaterAction(milliliters: Int) -> UNNotificationAction {
        return UNNotificationAction(identifier: NotificationAction.drunkWater(milliliters).rawValue,
                                    title: NotificationAction.drunkWater(milliliters).rawValue.localized,
                                    options: [])
    }
    
}
