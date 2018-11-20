//
//  SprintSchedulerService.swift
//  NotificationsKit
//
//  Created by i.kharabet on 19.11.2018.
//  Copyright © 2018 Илья Харабет. All rights reserved.
//

import Workset
import TasksKit
import UserNotifications

public final class SprintSchedulerService: BaseSchedulerService {
    
    public func scheduleSprint(_ sprint: Sprint) {
        removeSprintNotifications(sprint: sprint)
        
        guard sprint.notifications.isEnabled, let days = sprint.notifications.days else { return }
        
        var notificationStartDate = sprint.startDate
        notificationStartDate => (sprint.notifications.time?.0 ?? 0).asHours
        notificationStartDate => (sprint.notifications.time?.1 ?? 0).asMinutes
        
        (0..<7).forEach { day in
            let fireDate = notificationStartDate + day.asDays
            
            guard !(fireDate <= Date()) else { return }
            
            let dayNumber = fireDate.weekday - 1
            guard (days.map { $0.number }).contains(dayNumber) else { return }
            
            scheduleLocalNotification(withID: sprint.id,
                                      title: "Sprint".localized + " #\(sprint.number)",
                                      message: "sprint_notification_message".localized,
                                      at: fireDate,
                                      repeatUnit: .weekOfYear,
                                      category: "sprint",
                                      userInfo: ["sprint_id": sprint.id,
                                                 "end_date": sprint.endDate])
        }
    }
    
    public func removeSprintNotifications(sprint: Sprint) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiers = requests.filter { request in
                if let sprintID = request.content.userInfo["sprint_id"] as? String {
                    return sprintID == sprint.id
                }
                return false
            }.map { request in
                request.identifier
            }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
}
