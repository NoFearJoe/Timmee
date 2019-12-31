//
//  HabitEntity+Codable.swift
//  Synchronization
//
//  Created by i.kharabet on 23.01.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import TasksKit
import Firebase

extension HabitEntity: DictionaryEncodable {
    
    func encode() -> [String : Any] {
        let requiredFields = [
            "id": id as Any,
            "title": title as Any,
            "creationDate": creationDate as Any,
            "dueDays": dueDays as Any,
            "modificationDate": modificationDate
        ]
        
        var optionalFields: [String: Any] = [:]
        
        doneDates.map { optionalFields["doneDates"] = $0.compactMap { date in date as? Date } }
        notificationDate.map { optionalFields["notificationDate"] = $0 }
        repeatEndingDate.map { optionalFields["repeatEndingDate"] = $0 }
        link.map {optionalFields["link"] = $0 }
        value.map { optionalFields["value"] = $0 }
        note.map { optionalFields["note"] = $0 }
        dayTime.map { optionalFields["dayTime"] = $0 }
        goal.map { optionalFields["goalID"] = $0 }
        
        return requiredFields.merging(optionalFields, uniquingKeysWith: { old, new in new })
    }
    
}

extension HabitEntity: DictionaryDecodable {
    
    func decode(_ dictionary: [String : Any]) {
        id = dictionary["id"] as? String
        title = dictionary["title"] as? String
        creationDate = (dictionary["creationDate"] as? Timestamp)?.dateValue()
        if let doneDatesArray = dictionary["doneDates"] as? [Any] {
            doneDates = doneDatesArray.compactMap { ($0 as? Timestamp)?.dateValue() } as NSArray
        }
        dueDays = dictionary["dueDays"] as? String
        link = dictionary["link"] as? String
        note = dictionary["note"] as? String
        dayTime = dictionary["dayTime"] as? String
        notificationDate = (dictionary["notificationDate"] as? Timestamp)?.dateValue()
        repeatEndingDate = (dictionary["repeatEndingDate"] as? Timestamp)?.dateValue()
        value = dictionary["value"] as? String
        modificationDate = dictionary["modificationDate"] as? TimeInterval ?? 0
    }
    
}
