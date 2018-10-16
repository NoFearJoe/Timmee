//
//  TaskSchedulerService.swift
//  Timmee
//
//  Created by Ilya Kharabet on 22.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import Workset
import TasksKit
import NotificationCenter
import UserNotifications
import struct Foundation.Date
import class CoreLocation.CLLocation
import class CoreLocation.CLCircularRegion

public final class TaskSchedulerService: BaseSchedulerService {
    
    public func scheduleTask(_ task: Task) {
        removeNotifications(for: task)

        guard !task.isDone else { return }
        
//        let location = task.shouldNotifyAtLocation ? task.location : nil
        
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
                
                let userInfo = TaskSchedulerService.makeUserInfo(taskID: task.id, isDeferred: false, endDate: task.repeatEndingDate)
                scheduleLocalNotification(withID: task.id,
                                          title: task.title,
                                          message: TaskSchedulerService.makeNotificationMessage(for: task),
                                          at: notificationDate,
                                          repeatUnit: nil,
                                          userInfo: userInfo)
            case .every(let unit):
                if notificationDate <= Date() {
                    if let nextDueDate = task.nextDueDate {
                        notificationDate = nextDueDate
                    } else {
                        return
                    }
                }
                
                let userInfo = TaskSchedulerService.makeUserInfo(taskID: task.id, isDeferred: false, endDate: task.repeatEndingDate)
                scheduleLocalNotification(withID: task.id,
                                          title: task.title,
                                          message: TaskSchedulerService.makeNotificationMessage(for: task),
                                          at: notificationDate,
                                          repeatUnit: unit.calendarUnit,
                                          userInfo: userInfo)
            case .on(let unit):
                (0..<7).forEach { day in
                    let fireDate = notificationDate + day.asDays
                    
                    guard !(fireDate <= Date()) else { return }
                    
                    let dayNumber = fireDate.weekday - 1
                    if unit.dayNumbers.contains(dayNumber) {
                        let userInfo = TaskSchedulerService.makeUserInfo(taskID: task.id, isDeferred: false, endDate: task.repeatEndingDate)
                        scheduleLocalNotification(withID: task.id,
                                                  title: task.title,
                                                  message: TaskSchedulerService.makeNotificationMessage(for: task),
                                                  at: fireDate,
                                                  repeatUnit: .weekOfYear,
                                                  userInfo: userInfo)
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
                
                let userInfo = TaskSchedulerService.makeUserInfo(taskID: task.id, isDeferred: false, endDate: task.repeatEndingDate)
                scheduleLocalNotification(withID: task.id,
                                          title: task.title,
                                          message: TaskSchedulerService.makeNotificationMessage(for: task),
                                          at: fireDate,
                                          repeatUnit: nil,
                                          userInfo: userInfo)
            case .every(let unit):
                var fireDate = dueDate - notification.minutes.asMinutes
                
                if fireDate <= Date() {
                    if let nextDueDate = task.nextDueDate {
                        fireDate = nextDueDate - notification.minutes.asMinutes
                    } else {
                        return
                    }
                }
                
                let userInfo = TaskSchedulerService.makeUserInfo(taskID: task.id, isDeferred: false, endDate: task.repeatEndingDate)
                scheduleLocalNotification(withID: task.id,
                                          title: task.title,
                                          message: TaskSchedulerService.makeNotificationMessage(for: task),
                                          at: fireDate,
                                          repeatUnit: unit.calendarUnit,
                                          userInfo: userInfo)
            case .on(let unit):
                (0..<7).forEach { day in
                    let fireDate = dueDate + day.asDays - notification.minutes.asMinutes
                    
                    if fireDate <= Date() {
                        return
                    }
                    
                    let dayNumber = fireDate.weekday - 1
                    if unit.dayNumbers.contains(dayNumber) {
                        let userInfo = TaskSchedulerService.makeUserInfo(taskID: task.id, isDeferred: false, endDate: task.repeatEndingDate)
                        scheduleLocalNotification(withID: task.id,
                                                  title: task.title,
                                                  message: TaskSchedulerService.makeNotificationMessage(for: task),
                                                  at: fireDate,
                                                  repeatUnit: .weekOfYear,
                                                  userInfo: userInfo)
                    }
                }
            }
        } else if task.shouldNotifyAtLocation {
//            let userInfo = TaskSchedulerService.makeUserInfo(taskID: task.id, isDeferred: false, endDate: task.repeatEndingDate)
//            scheduleLocalNotification(withID: task.id,
//                                      title: task.title,
//                                      message: TaskSchedulerService.makeNotificationMessage(for: task),
//                                      at: nil,
//                                      repeatUnit: nil,
//                                      userInfo: userInfo)
        }
    }
    
    /**
     Создает уведомление для задачи, которую пользователь перенес на другое время
     */
    public func scheduleDeferredTask(_ task: Task, fireDate: Date) {
        removeDeferredNotifications(for: task)
        
        guard !task.isDone else { return }
        
//        let location = task.shouldNotifyAtLocation ? task.location : nil
        
        let userInfo = TaskSchedulerService.makeUserInfo(taskID: task.id, isDeferred: true, endDate: task.repeatEndingDate)
        scheduleLocalNotification(withID: task.id,
                                  title: task.title,
                                  message: TaskSchedulerService.makeNotificationMessage(for: task),
                                  at: fireDate,
                                  repeatUnit: nil,
                                  userInfo: userInfo)
    }
    
    public func removeNotifications(for task: Task) {
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
    }
    
    public func removeDeferredNotifications(for task: Task) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiers = requests.filter { request in
                    if let taskID = request.content.userInfo["task_id"] as? String, let isDeferred = request.content.userInfo["isDeferred"] as? Bool {
                        return taskID == task.id && isDeferred
                    }
                    return false
                }.map { request in
                    request.identifier
                }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }

}

private extension TaskSchedulerService {
    
    static func makeNotificationMessage(for task: Task) -> String {
        if let dueDate = task.dueDate {
            return dueDate.asNearestDateString
        }
        return task.note
    }
    
    static func makeUserInfo(taskID: String, isDeferred: Bool, endDate: Date?) -> [String: Any] {
        var userInfo = ["task_id": taskID, "isDeferred": isDeferred] as [String : Any]
        if let endDate = endDate {
            userInfo["end_date"] = endDate
        }
        return userInfo
    }
    
}
