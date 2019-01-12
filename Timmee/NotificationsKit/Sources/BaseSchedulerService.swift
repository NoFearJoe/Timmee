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
    
    final func scheduleLocalNotification(withID id: String,
                                         title: String,
                                         message: String,
                                         at date: Date,
                                         repeatUnit: NSCalendar.Unit?,
                                         category: String = "task",
                                         userInfo: [String: Any]) {
        let request = makeLocalNotification(withID: id, title: title, message: message, at: date, repeatUnit: repeatUnit, category: category, userInfo: userInfo)
        UNUserNotificationCenter.current().add(request)
    }
    
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
        content.badge = 1
        
        let triggerDateComponents = makeTriggerDateComponents(from: date.startOfMinute, repeatUnit: repeatUnit)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: repeatUnit != nil)
        return UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    }
    
    private func makeTriggerDateComponents(from date: Date, repeatUnit: NSCalendar.Unit?) -> DateComponents {
        switch repeatUnit {
        case .minute?: return Calendar.current.dateComponents([.second], from: date)
        case .hour?: return Calendar.current.dateComponents([.minute, .second], from: date)
        case .day?: return Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        case .weekOfYear?: return Calendar.current.dateComponents([.weekday, .hour, .minute, .second], from: date)
        case .month?: return Calendar.current.dateComponents([.day, .hour, .minute, .second], from: date)
        case .year?: return Calendar.current.dateComponents([.month, .day, .hour, .minute, .second], from: date)
        default: return Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second], from: date)
        }
    }
    
}
