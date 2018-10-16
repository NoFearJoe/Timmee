//
//  BaseSchedulerService.swift
//  NotificationsKit
//
//  Created by Илья Харабет on 16/10/2018.
//  Copyright © 2018 Илья Харабет. All rights reserved.
//

import UserNotifications
import class CoreLocation.CLLocation
import class CoreLocation.CLCircularRegion

public class BaseSchedulerService {
    
    public init() {}
    
    private func makeLocalNotification(withID id: String,
                                       title: String,
                                       message: String,
                                       at date: Date,
                                       repeatUnit: NSCalendar.Unit?,
                                       category: String = "task",
                                       userInfo: [String: Any]) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = category
        content.title = title
        content.body = message
        content.userInfo = userInfo
        content.sound = UNNotificationSound.default
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents(in: .current, from: date.startOfMinute), repeats: false)
        return UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    }
    
    final func scheduleLocalNotification(withID id: String,
                                         title: String,
                                         message: String,
                                         at date: Date,
                                         repeatUnit: NSCalendar.Unit?,
                                         category: String = "task",
                                         userInfo: [String: Any]) {
//        let request = makeLocalNotification(withID: id, title: title, message: message, at: date, repeatUnit: repeatUnit, category: category, userInfo: userInfo)
//        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        let notification = UILocalNotification()
        notification.fireDate = date.startOfMinute
        notification.timeZone = TimeZone.current
        notification.alertTitle = title
        notification.alertBody = message
        notification.repeatCalendar = NSCalendar.current
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.category = category

        if let unit = repeatUnit {
            notification.repeatInterval = unit
        }

        notification.userInfo = userInfo

//        if let location = location {
//            notification.region = CLCircularRegion(center: location.coordinate,
//                                                   radius: 100,
//                                                   identifier: location.description)
//            notification.region?.notifyOnEntry = true
//            notification.regionTriggersOnce = false
//        }
        
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
}
