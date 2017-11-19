//
//  TaskSchedulerService.swift
//  Timmee
//
//  Created by Ilya Kharabet on 22.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date
import NotificationCenter
import UserNotifications
import class CoreLocation.CLLocation
import class CoreLocation.CLCircularRegion

final class TaskSchedulerService {

    func scheduleTask(_ task: Task, listTitle: String) {
        guard !task.isDone else { return }
        
        let location = task.shouldNotifyAtLocation ? task.location : nil
        
        if let dueDate = task.dueDate, task.notification != .doNotNotify {
            switch task.repeating.type {
            case .never:
                let fireDate = dueDate - task.notification.minutes.asMinutes
                scheduleLocalNotification(withID: task.id,
                                          title: listTitle,
                                          message: task.title,
                                          at: fireDate,
                                          repeatUnit: nil,
                                          end: task.repeatEndingDate,
                                          location: location)
            case .every(let unit):
                var date = dueDate
                (0..<task.repeating.value).forEach { index in
                    if index > 0 {
                        switch unit {
                        case .day: date = date + index.asDays
                        case .week: date = date + index.asWeeks
                        case .month: date = date + index.asMonths
                        case .year: date = date + index.asYears
                        }
                    }
                    let fireDate = date - task.notification.minutes.asMinutes
                    scheduleLocalNotification(withID: task.id,
                                              title: listTitle,
                                              message: task.title,
                                              at: fireDate,
                                              repeatUnit: unit.calendarUnit,
                                              end: task.repeatEndingDate,
                                              location: location)
                }
            case .on(let unit):
                (0..<7).forEach { day in
                    let fireDate = dueDate + day.asDays
                    let dayNumber = fireDate.weekday
                    if unit.dayNumbers.contains(dayNumber) {
                        scheduleLocalNotification(withID: task.id,
                                                  title: listTitle,
                                                  message: task.title,
                                                  at: fireDate,
                                                  repeatUnit: .weekOfMonth,
                                                  end: task.repeatEndingDate,
                                                  location: location)
                    }
                }
            }
        } else if task.shouldNotifyAtLocation {
            scheduleLocalNotification(withID: task.id,
                                      title: listTitle,
                                      message: task.title,
                                      at: nil,
                                      repeatUnit: nil,
                                      end: task.repeatEndingDate,
                                      location: location)
        }
    }

}

fileprivate extension TaskSchedulerService {

    func scheduleLocalNotification(withID id: String,
                                   title: String,
                                   message: String,
                                   at date: Date?,
                                   repeatUnit: NSCalendar.Unit?,
                                   end: Date?,
                                   location: CLLocation?) {
        let notification = UILocalNotification()
        notification.fireDate = date
        notification.timeZone = TimeZone.current
        notification.alertTitle = title
        notification.alertBody = message
        notification.repeatCalendar = NSCalendar.current
        notification.category = "task"
        
        if let unit = repeatUnit {
            notification.repeatInterval = unit
        }
        
        notification.userInfo = ["task_id": id]
        if let endDate = end {
            notification.userInfo?["end_date"] = endDate
        }
        
        if let location = location {
            notification.region = CLCircularRegion(center: location.coordinate,
                                                   radius: 100,
                                                   identifier: location.description)
            notification.region?.notifyOnEntry = true
            notification.regionTriggersOnce = false
        }
        
        if let notifications = UIApplication.shared.scheduledLocalNotifications {
            if let index = notifications.index(where: {
                if let taskID = $0.userInfo?["task_id"] as? String {
                    return taskID == id
                }
                return false
            }) {
//                if #available(iOS 10.0, *) {
//                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [])
//                } else {
                    UIApplication.shared.cancelLocalNotification(notifications[index])
//                }
            }
        }
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    func scheduleLocationNotification() {
        
    }

}
