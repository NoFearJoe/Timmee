//
//  TaskSchedulerService.swift
//  Timmee
//
//  Created by Ilya Kharabet on 22.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date
import MTDates
import NotificationCenter
import UserNotifications
import class CoreLocation.CLLocation
import class CoreLocation.CLCircularRegion

final class TaskSchedulerService {

    func scheduleTask(_ task: Task, listTitle: String) {
        let location = task.shouldNotifyAtLocation ? task.location : nil
        
        if let dueDate = task.dueDate, task.notification != .doNotNotify {
            switch task.repeating.type {
            case .never:
                let fireDate = (dueDate as NSDate).mt_dateMinutes(before: task.notification.minutes)
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
                        case .day: date = (date as NSDate).mt_dateDays(after: index)
                        case .week: date = (date as NSDate).mt_dateWeeks(after: index)
                        case .month: date = (date as NSDate).mt_dateMonths(after: index)
                        case .year: date = (date as NSDate).mt_dateYears(after: index)
                        }
                    }
                    let fireDate = (date as NSDate).mt_dateMinutes(before: task.notification.minutes)
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
                    guard let fireDate = (dueDate as NSDate).mt_dateDays(after: day) else { return }
                    let dayNumber = (fireDate as NSDate).mt_weekdayOfWeek()
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
