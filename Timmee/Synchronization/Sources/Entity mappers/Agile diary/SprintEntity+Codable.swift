//
//  SprintEntity+Codable.swift
//  Synchronization
//
//  Created by i.kharabet on 23.01.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import TasksKit
import Firebase

extension SprintEntity: DictionaryEncodable {
    
    func encode() -> [String : Any] {
        let requiredFields = [
            "id": id as Any,
            "endDate": endDate as Any,
            "isReady": isReady,
            "notificationsEnabled": notificationsEnabled,
            "number": number,
            "startDate": startDate as Any,
            "title": title as Any,
            "modificationDate": modificationDate,
            "modificationAuthor": (modificationAuthor ?? SprintEntity.currentAuthor) as Any
        ]
        
        var optionalFields: [String: Any] = [:]
        
        notificationsDays.map { optionalFields["notificationDays"] = $0 }
        notificationsTime.map { optionalFields["notificationsTime"] = $0 }
        
        return requiredFields.merging(optionalFields, uniquingKeysWith: { old, new in new })
    }
    
}

extension SprintEntity: DictionaryDecodable {

    func decode(_ dictionary: [String : Any]) {
        id = dictionary["id"] as? String
        endDate = (dictionary["endDate"] as? Timestamp)?.dateValue()
        isReady = dictionary["isReady"] as? Bool ?? false
        notificationsEnabled = dictionary["notificationsEnabled"] as? Bool ?? false
        number = dictionary["number"] as? Int32 ?? 0
        startDate = (dictionary["startDate"] as? Timestamp)?.dateValue()
        title = dictionary["title"] as? String
        notificationsDays = dictionary["notificationsDays"] as? String
        notificationsTime = dictionary["notificationsTime"] as? String
        modificationDate = dictionary["modificationDate"] as? TimeInterval ?? 0
        modificationAuthor = dictionary["modificationAuthor"] as? String
    }
    
}
