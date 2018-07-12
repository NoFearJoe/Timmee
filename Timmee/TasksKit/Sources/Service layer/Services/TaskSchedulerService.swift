//
//  TaskSchedulerService.swift
//  Timmee
//
//  Created by Ilya Kharabet on 22.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import Workset
import struct Foundation.Date
import NotificationCenter
import UserNotifications
import class CoreLocation.CLLocation
import class CoreLocation.CLCircularRegion

public final class TaskSchedulerService {

    public init() {}
    
    public func scheduleTask(_ task: Task) {
        removeNotifications(for: task)

        guard !task.isDone else { return }
        
        let location = task.shouldNotifyAtLocation ? task.location : nil
        
        let notification = task.timeTemplate?.notification ?? task.notification
        
        if var notificationDate = task.notificationDate {
            switch task.repeating.type {
            case .never:
                if notificationDate <= Date() {
                    if let nextDueDate = task.nextDueDate {
                        notificationDate = nextDueDate
                    } else {
                        return
                    }
                }
                
                scheduleLocalNotification(withID: task.id,
                                          title: task.title,
                                          message: TaskSchedulerService.makeNotificationMessage(for: task),
                                          at: notificationDate,
                                          repeatUnit: nil,
                                          end: task.repeatEndingDate,
                                          location: location)
            case .every(let unit):
                if notificationDate <= Date() {
                    if let nextDueDate = task.nextDueDate {
                        notificationDate = nextDueDate
                    } else {
                        return
                    }
                }
                
                scheduleLocalNotification(withID: task.id,
                                          title: task.title,
                                          message: TaskSchedulerService.makeNotificationMessage(for: task),
                                          at: notificationDate,
                                          repeatUnit: unit.calendarUnit,
                                          end: task.repeatEndingDate,
                                          location: location)
            case .on(let unit):
                (0..<7).forEach { day in
                    let fireDate = notificationDate + day.asDays
                    
                    guard !(fireDate <= Date()) else { return }
                    
                    let dayNumber = fireDate.weekday - 1
                    if unit.dayNumbers.contains(dayNumber) {
                        scheduleLocalNotification(withID: task.id,
                                                  title: task.title,
                                                  message: TaskSchedulerService.makeNotificationMessage(for: task),
                                                  at: fireDate,
                                                  repeatUnit: .weekOfYear,
                                                  end: task.repeatEndingDate,
                                                  location: location)
                    }
                }
            }
        } else if let dueDate = task.dueDate, notification != .doNotNotify {
            switch task.repeating.type {
            case .never:
                var fireDate = dueDate - notification.minutes.asMinutes
                
                if fireDate <= Date() {
                    if let nextDueDate = task.nextDueDate {
                        fireDate = nextDueDate - notification.minutes.asMinutes
                    } else {
                        return
                    }
                }
                
                scheduleLocalNotification(withID: task.id,
                                          title: task.title,
                                          message: TaskSchedulerService.makeNotificationMessage(for: task),
                                          at: fireDate,
                                          repeatUnit: nil,
                                          end: task.repeatEndingDate,
                                          location: location)
            case .every(let unit):
                var fireDate = dueDate - notification.minutes.asMinutes
                
                if fireDate <= Date() {
                    if let nextDueDate = task.nextDueDate {
                        fireDate = nextDueDate - notification.minutes.asMinutes
                    } else {
                        return
                    }
                }
                
                scheduleLocalNotification(withID: task.id,
                                          title: task.title,
                                          message: TaskSchedulerService.makeNotificationMessage(for: task),
                                          at: fireDate,
                                          repeatUnit: unit.calendarUnit,
                                          end: task.repeatEndingDate,
                                          location: location)
            case .on(let unit):
                (0..<7).forEach { day in
                    let fireDate = dueDate + day.asDays - notification.minutes.asMinutes
                    
                    if fireDate <= Date() {
                        return
                    }
                    
                    let dayNumber = fireDate.weekday - 1
                    if unit.dayNumbers.contains(dayNumber) {
                        scheduleLocalNotification(withID: task.id,
                                                  title: task.title,
                                                  message: TaskSchedulerService.makeNotificationMessage(for: task),
                                                  at: fireDate,
                                                  repeatUnit: .weekOfYear,
                                                  end: task.repeatEndingDate,
                                                  location: location)
                    }
                }
            }
        } else if task.shouldNotifyAtLocation {
            scheduleLocalNotification(withID: task.id,
                                      title: task.title,
                                      message: TaskSchedulerService.makeNotificationMessage(for: task),
                                      at: nil,
                                      repeatUnit: nil,
                                      end: task.repeatEndingDate,
                                      location: location)
        }
    }
    
    /**
     Создает уведомление для задачи, которую пользователь перенес на другое время
     */
    public func scheduleDeferredTask(_ task: Task, fireDate: Date) {
        removeDeferredNotifications(for: task)
        
        guard !task.isDone else { return }
        
        let location = task.shouldNotifyAtLocation ? task.location : nil
                
        scheduleLocalNotification(withID: task.id,
                                  title: task.title,
                                  message: TaskSchedulerService.makeNotificationMessage(for: task),
                                  at: fireDate,
                                  repeatUnit: nil,
                                  end: task.repeatEndingDate,
                                  location: location,
                                  isDeferred: true)
    }
    
    public func removeNotifications(for task: Task) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                let identifiers = requests.filter { request in
                        if let taskID = request.content.userInfo["task_id"] as? String {
                            return taskID == task.id
                        }
                        return false
                    }.map { request in
                        request.identifier
                    }
                
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
            }
        } else {
            if let notifications = UIApplication.shared.scheduledLocalNotifications {
                notifications.forEach { notification in
                    if let taskID = notification.userInfo?["task_id"] as? String, taskID == task.id {
                        UIApplication.shared.cancelLocalNotification(notification)
                    }
                }
            }
        }
    }
    
    public func removeDeferredNotifications(for task: Task) {
        if let notifications = UIApplication.shared.scheduledLocalNotifications {
            notifications.forEach { notification in
                guard let taskID = notification.userInfo?["task_id"] as? String, taskID == task.id else { return }
                guard let isDeferred = notification.userInfo?["isDeferred"] as? Bool, isDeferred else { return }
                UIApplication.shared.cancelLocalNotification(notification)
            }
        }
    }

}

private extension TaskSchedulerService {

    func scheduleLocalNotification(withID id: String,
                                   title: String,
                                   message: String,
                                   at date: Date?,
                                   repeatUnit: NSCalendar.Unit?,
                                   end: Date?,
                                   location: CLLocation?,
                                   isDeferred: Bool = false) {
        let notification = UILocalNotification()
        notification.fireDate = date?.startOfMinute
        notification.timeZone = TimeZone.current
        notification.alertTitle = title
        notification.alertBody = message
        notification.repeatCalendar = NSCalendar.current
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.category = "task"
        
        if let unit = repeatUnit {
            notification.repeatInterval = unit
        }
        
        notification.userInfo = ["task_id": id]
        if let endDate = end {
            notification.userInfo?["end_date"] = endDate
        }
        notification.userInfo?["isDeferred"] = isDeferred
        
        if let location = location {
            notification.region = CLCircularRegion(center: location.coordinate,
                                                   radius: 100,
                                                   identifier: location.description)
            notification.region?.notifyOnEntry = true
            notification.regionTriggersOnce = false
        }
        
        UIApplication.shared.scheduleLocalNotification(notification)
    }

}

private extension TaskSchedulerService {
    
    static func makeNotificationMessage(for task: Task) -> String {
        if let dueDate = task.dueDate {
            return dueDate.asNearestDateString
        }
        return task.note
    }
    
}
