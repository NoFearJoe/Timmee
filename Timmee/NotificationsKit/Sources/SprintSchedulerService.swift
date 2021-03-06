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
        removeSprintNotifications(sprint: sprint) {
            self.scheduleNewSprint(sprint)
            self.scheduleSprintFinishedNotification(sprint)
        }
    }
    
    private func scheduleNewSprint(_ sprint: Sprint) {
        guard sprint.notifications.isEnabled, let days = sprint.notifications.days else { return }
        
        var notificationStartDate = sprint.startDate
        notificationStartDate => (sprint.notifications.time?.0 ?? 0).asHours
        notificationStartDate => (sprint.notifications.time?.1 ?? 0).asMinutes
        
        (0..<7).forEach { day in
            let fireDate = notificationStartDate + day.asDays
            
            guard !(fireDate <= Date()) else { return }
            guard (days.map { $0.weekday }).contains(fireDate.weekday) else { return }
            
            scheduleLocalNotification(withID: sprint.id + "\(fireDate.weekday)",
                                      title: sprint.title,
                                      message: "sprint_notification_message".localized,
                                      at: fireDate,
                                      repeatUnit: .weekOfYear,
                                      category: "sprint",
                                      userInfo: ["sprint_id": sprint.id,
                                                 "end_date": sprint.endDate])
        }
    }
    
    private func scheduleSprintFinishedNotification(_ sprint: Sprint) {
        scheduleLocalNotification(withID: sprint.id + "finished",
                                  title: sprint.title,
                                  message: "sprint_has_finished_notification_message".localized,
                                  at: sprint.endDate,
                                  repeatUnit: nil,
                                  userInfo: ["sprint_id": sprint.id,
                                             "end_date": sprint.endDate])
    }
    
    public func removeSprintNotifications(sprint: Sprint, completion: @escaping () -> Void) {
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
            
            completion()
        }
    }
    
}
