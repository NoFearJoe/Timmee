//
//  TimeTemplate.swift
//  Timmee
//
//  Created by Ilya Kharabet on 12.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date
import class Foundation.NSDate

public final class TimeTemplate {
    public var id: String
    public var title: String
    public var time: (hours: Int, minutes: Int)?
    public var notification: NotificationMask?
    public var notificationTime: (Int, Int)?
    
    public init(id: String,
                title: String,
                time: (hours: Int, minutes: Int)?,
                notification: NotificationMask?,
                notificationTime: (Int, Int)?) {
        self.id = id
        self.title = title
        self.time = time
        self.notification = notification
        self.notificationTime = notificationTime
    }
    
    public init(entity: TimeTemplateEntity) {
        id = entity.id ?? ""
        title = entity.title ?? ""
        if let hours = entity.hours?.int16Value, let minutes = entity.minutes?.int16Value {
            time = (Int(hours), Int(minutes))
        } else {
            time = nil
        }
        notification = entity.notification.flatMap { NotificationMask(mask: $0.int16Value) }
        if let notificationTimeUnits = entity.notificationTime?.split(separator: ":").compactMap({ Int($0) }), notificationTimeUnits.count == 2 {
            notificationTime = (notificationTimeUnits[0], notificationTimeUnits[1])
        } else {
            notificationTime = nil
        }
    }
}

extension TimeTemplate {
    public func makeDueTimeAndNotificationString() -> String {
        var dueTimeString = ""
        if let time = self.time {
            let minutes: String
            if time.minutes < 10 {
                minutes = "\(time.minutes)0"
            } else {
                minutes = "\(time.minutes)"
            }
            
            dueTimeString = "\(time.hours):\(minutes), "
        }
        
        if let notificationTime = self.notificationTime {
            let notificationTimeString = "\(notificationTime.0):\(notificationTime.1)"
            let fullString = dueTimeString + "remind".localized + " " + "at".localized + " " + notificationTimeString
            return fullString.capitalizedFirst
        } else {
            let notification = self.notification ?? .doNotNotify
            let fullString = dueTimeString + notification.title
            return fullString.capitalizedFirst
        }
    }
}

extension TimeTemplate: Equatable {
    public static func ==(lhs: TimeTemplate, rhs: TimeTemplate) -> Bool {
        return lhs.id == rhs.id
    }
}
