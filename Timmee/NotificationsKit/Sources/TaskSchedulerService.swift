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
        removeNotifications(for: task) {
            self.scheduleNewTask(task)
        }
    }
    
    /**
     Создает уведомление для задачи, которую пользователь перенес на другое время
     */
    public func scheduleDeferredTask(_ task: Task, fireDate: Date) {
        removeDeferredNotifications(for: task) {
            self.scheduleNewDeferredTask(task, fireDate: fireDate)
        }
    }
    
    private func scheduleNewTask(_ task: Task) {
        guard !task.isDone(at: nil) && !task.isFinished(at: Date()) else { return }
        
        //        let location = task.shouldNotifyAtLocation ? task.location : nil
        
        let notification = task.timeTemplate?.notification ?? task.notification
        
        switch task.repeating.type {
        case .never:
            let fireDate: Date
            
            if let notificationDate = task.notificationDate {
                if notificationDate <= Date() {
                    guard let nextDueDate = task.nextDueDate else { return }
                    fireDate = nextDueDate
                } else {
                    fireDate = notificationDate
                }
            } else if let notificationTime = task.notificationTime, let dueDate = task.dueDate {
                guard let notificationDate = TaskSchedulerService.makeNotificationDate(dueDate: dueDate,
                                                                                       notificationTime: notificationTime,
                                                                                       task: task) else { return }
                fireDate = notificationDate
            } else if let dueDate = task.dueDate, notification != .doNotNotify {
                let notificationDate = dueDate - notification.minutes.asMinutes
                if notificationDate <= Date() {
                    guard let nextDueDate = task.nextDueDate else { return }
                    fireDate = nextDueDate - notification.minutes.asMinutes
                } else {
                    fireDate = notificationDate
                }
            } else {
                return
            }
            
            let userInfo = TaskSchedulerService.makeUserInfo(taskID: task.id, isDeferred: false, endDate: task.repeatEndingDate)
            scheduleLocalNotification(withID: task.id,
                                      title: task.title,
                                      message: TaskSchedulerService.makeNotificationMessage(for: task),
                                      at: fireDate,
                                      repeatUnit: nil,
                                      userInfo: userInfo)
        case .every(let unit):
            let fireDate: Date
            
            // Напоминание для регулярной задачи можно сделать только если установлено время напоминания
            
            if let notificationTime = task.notificationTime, let dueDate = task.dueDate {
                guard let notificationDate = TaskSchedulerService.makeNotificationDate(dueDate: dueDate,
                                                                                       notificationTime: notificationTime,
                                                                                       task: task) else { return }
                fireDate = notificationDate
            } else {
                return
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
                guard let notificationTime = task.notificationTime, let dueDate = task.dueDate else { return }
                
                var fireDate = dueDate + day.asDays
                fireDate => notificationTime.0.asHours
                fireDate => notificationTime.1.asMinutes
                
                if fireDate <= Date() { return }
                
                let dayNumber = DayUnit(weekday: fireDate.weekday).number
                if unit.dayNumbers.contains(dayNumber) {
                    let userInfo = TaskSchedulerService.makeUserInfo(taskID: task.id, isDeferred: false, endDate: task.repeatEndingDate)
                    scheduleLocalNotification(withID: task.id + "\(fireDate.weekday)",
                                              title: task.title,
                                              message: TaskSchedulerService.makeNotificationMessage(for: task),
                                              at: fireDate,
                                              repeatUnit: .weekOfYear,
                                              userInfo: userInfo)
                }
            }
        }
        
        //        } else if task.shouldNotifyAtLocation {
        //            let userInfo = TaskSchedulerService.makeUserInfo(taskID: task.id, isDeferred: false, endDate: task.repeatEndingDate)
        //            scheduleLocalNotification(withID: task.id,
        //                                      title: task.title,
        //                                      message: TaskSchedulerService.makeNotificationMessage(for: task),
        //                                      at: nil,
        //                                      repeatUnit: nil,
        //                                      userInfo: userInfo)
        //        }
    }
    
    public func scheduleNewDeferredTask(_ task: Task, fireDate: Date) {
        guard !task.isDone(at: nil) && !task.isFinished(at: Date()) else { return }
        
        //        let location = task.shouldNotifyAtLocation ? task.location : nil
        
        let userInfo = TaskSchedulerService.makeUserInfo(taskID: task.id, isDeferred: true, endDate: task.repeatEndingDate)
        scheduleLocalNotification(withID: task.id + "\(fireDate.weekday)",
                                  title: task.title,
                                  message: TaskSchedulerService.makeNotificationMessage(for: task),
                                  at: fireDate,
                                  repeatUnit: nil,
                                  userInfo: userInfo)
    }
    
    public func removeNotifications(for task: Task, completion: (() -> Void)? = nil) {
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
            
            DispatchQueue.main.async { completion?() }
        }
    }
    
    public func removeDeferredNotifications(for task: Task, completion: (() -> Void)? = nil) {
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
            
            DispatchQueue.main.async { completion?() }
        }
    }

}

private extension TaskSchedulerService {
    
    static func makeNotificationMessage(for task: Task) -> String {
        if let dueDate = task.dueDate, task.kind == .single {
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
    
    static func makeNotificationDate(dueDate: Date, notificationTime: (Int, Int), task: Task) -> Date? {
        var notificationDate = dueDate
        notificationDate => notificationTime.0.asHours
        notificationDate => notificationTime.1.asMinutes
        return task.getNextRepeatDate(of: notificationDate)
    }
    
}
