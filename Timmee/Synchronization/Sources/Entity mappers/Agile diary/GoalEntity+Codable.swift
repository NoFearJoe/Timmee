//
//  GoalEntity+Codable.swift
//  Synchronization
//
//  Created by i.kharabet on 23.01.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import TasksKit
import Firebase

extension GoalEntity: DictionaryEncodable {
    
    func encode() -> [String : Any] {
        let requiredFields = [
            "id": id as Any,
            "creationDate": creationDate as Any,
            "isDone": isDone,
            "title": title as Any,
            "modificationDate": modificationDate
        ]
        
        var optionalFields: [String: Any] = [:]
        
        note.map { optionalFields["note"] = $0 }
        
        return requiredFields.merging(optionalFields, uniquingKeysWith: { old, new in new })
    }
    
}

extension GoalEntity: DictionaryDecodable {
    
    func decode(_ dictionary: [String : Any]) {
        id = dictionary["id"] as? String
        creationDate = (dictionary["creationDate"] as? Timestamp)?.dateValue()
        isDone = dictionary["isDone"] as? Bool ?? false
        title = dictionary["title"] as? String
        note = dictionary["note"] as? String
        modificationDate = dictionary["modificationDate"] as? TimeInterval ?? 0
    }
    
}
