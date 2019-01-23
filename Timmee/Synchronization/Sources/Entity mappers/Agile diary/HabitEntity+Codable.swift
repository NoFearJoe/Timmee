//
//  HabitEntity+Codable.swift
//  Synchronization
//
//  Created by i.kharabet on 23.01.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import TasksKit

extension HabitEntity: DictionaryEncodable {
    
    func encode() -> [String : Any] {
        let requiredFields = [
            "id": id as Any,
            "title": title as Any,
            "creationDate": creationDate as Any,
            "dueDays": dueDays as Any,
        ]
        
        var optionalFields: [String: Any] = [:]
        
        doneDates.map { optionalFields["doneDates"] = $0.compactMap { date in date as? Date } }
        notificationDate.map { optionalFields["notificationDate"] = $0 }
        repeatEndingDate.map { optionalFields["repeatEndingDate"] = $0 }
        link.map {optionalFields["link"] = $0 }
        value.map { optionalFields["value"] = $0 }
        note.map { optionalFields["note"] = $0 }
        
        return requiredFields.merging(optionalFields, uniquingKeysWith: { old, new in new })
    }
    
}

extension HabitEntity: DictionaryDecodable {
    
    func decode(_ dictionary: [String : Any]) {
        id = dictionary["id"] as? String
        title = dictionary["title"] as? String
        creationDate = dictionary["creationDate"] as? Date
        doneDates = dictionary["doneDates"] as? NSArray // FIXME?
        dueDays = dictionary["dueDays"] as? String
        link = dictionary["link"] as? String
        note = dictionary["note"] as? String
        notificationDate = dictionary["notificationDate"] as? Date
        repeatEndingDate = dictionary["repeatEndingDate"] as? Date
        value = dictionary["value"] as? String
    }
    
}
