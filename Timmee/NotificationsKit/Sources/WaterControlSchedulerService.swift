//
//  WaterControlSchedulerService.swift
//  NotificationsKit
//
//  Created by Илья Харабет on 16/10/2018.
//  Copyright © 2018 Илья Харабет. All rights reserved.
//

import Workset
import TasksKit
import UserNotifications

public final class WaterControlSchedulerService: BaseSchedulerService {
    
    public func scheduleWaterControl(_ waterControl: WaterControl, startDate: Date, endDate: Date) {
        removeWaterControlNotifications()
        
        guard waterControl.notificationsEnabled else { return }
        
        let endHours = waterControl.notificationsEndTime.hours
        var date = startDate.compare(Date().startOfDay) == .orderedDescending ? startDate : Date().startOfDay
        date => waterControl.notificationsStartTime.hours.asHours
        date => waterControl.notificationsStartTime.minutes.asMinutes
        while date.hours < endHours {
            scheduleLocalNotification(withID: "water_control",
                                      title: "water_time_title".localized,
                                      message: "water_time_subtitle".localized,
                                      at: date,
                                      repeatUnit: .day,
                                      category: "water_control",
                                      userInfo: [:])
            date = date + waterControl.notificationsInterval.asHours
        }
    }
    
    public func removeWaterControlNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiers = requests.filter { request in
                if let taskID = request.content.userInfo["task_id"] as? String {
                    return taskID == "water_control"
                }
                return false
                }.map { request in
                    request.identifier
            }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
}
