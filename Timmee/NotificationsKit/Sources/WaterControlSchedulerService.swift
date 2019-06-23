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
        removeWaterControlNotifications(waterControl) {
            self.scheduleNewWaterControl(waterControl, startDate: startDate, endDate: endDate)
        }
    }
    
    private func scheduleNewWaterControl(_ waterControl: WaterControl, startDate: Date, endDate: Date) {
        guard waterControl.notificationsEnabled else { return }
        
        let endHours = waterControl.notificationsEndTime.hours
        var date = startDate.compare(Date().startOfDay) == .orderedDescending ? startDate : Date().startOfDay
        date => waterControl.notificationsStartTime.hours.asHours
        date => waterControl.notificationsStartTime.minutes.asMinutes
        while date.hours < endHours {
            scheduleLocalNotification(withID: waterControl.id,
                                      title: "water_time_title".localized,
                                      message: "water_time_subtitle".localized,
                                      at: date,
                                      repeatUnit: .day,
                                      category: "water_control",
                                      userInfo: ["water_control_id": waterControl.id])
            date = date + waterControl.notificationsInterval.asHours
        }
    }
    
    public func removeWaterControlNotifications(_ waterControl: WaterControl, completion: @escaping () -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiers = requests.filter { request in
                    if let id = request.content.userInfo["water_control_id"] as? String {
                        return id == waterControl.id
                    }
                    return false
                }.map { request in
                    request.identifier
                }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
            
            completion()
        }
    }
    
}
