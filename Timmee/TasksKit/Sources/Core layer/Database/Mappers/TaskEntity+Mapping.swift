//
//  TaskEntity+Mapping.swift
//  Timmee
//
//  Created by Ilya Kharabet on 02.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foundation.NSDate
import class Foundation.NSData
import class Foundation.NSArray
import class Foundation.NSKeyedArchiver
import struct CoreLocation.CLLocationCoordinate2D

public extension TaskEntity {

    public func map(from entity: Task) {
        id = entity.id
        kind = entity.kind.rawValue
        title = entity.title
        isImportant = entity.isImportant
        notificationMask = entity.notification.rawValue
        notificationDate = entity.notificationDate
        notificationTime = entity.notificationTime.flatMap { "\($0.0):\($0.1)" }
        note = entity.note
        link = entity.link
        repeatMask = entity.repeating.string
        dueDate = entity.dueDate
        repeatEndingDate = entity.repeatEndingDate
        doneDates = entity.doneDates as NSArray
        
//        if let location = entity.location {
//            self.location = NSKeyedArchiver.archivedData(withRootObject: location)
//        } else {
//            self.location = nil
//        }
//        address = entity.address
        
//        shouldNotifyAtLocation = entity.shouldNotifyAtLocation
        
        isDone = entity.isDone
        inProgress = entity.inProgress
        creationDate = entity.creationDate
        
        attachments = entity.attachments as NSArray
    }

}
