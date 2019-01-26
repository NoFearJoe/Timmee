//
//  SubtaskEntity+Codable.swift
//  Synchronization
//
//  Created by i.kharabet on 23.01.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import TasksKit
import Firebase

extension SubtaskEntity: DictionaryEncodable {
    
    func encode() -> [String : Any] {
        let requiredFields = [
            "id": id as Any,
            "creationDate": creationDate as Any,
            "isDone": isDone,
            "sortPosition": sortPosition,
            "title": title as Any,
            "modificationDate": modificationDate
        ]
        
        let optionalFields: [String: Any] = [:]
        
        return requiredFields.merging(optionalFields, uniquingKeysWith: { old, new in new })
    }
    
}

extension SubtaskEntity: DictionaryDecodable {
    
    func decode(_ dictionary: [String : Any]) {
        id = dictionary["id"] as? String
        creationDate = (dictionary["creationDate"] as? Timestamp)?.dateValue()
        isDone = dictionary["isDone"] as? Bool ?? false
        sortPosition = dictionary["sortPosition"] as? Int32 ?? 0
        title = dictionary["title"] as? String
        modificationDate = dictionary["modificationDate"] as? TimeInterval ?? 0
    }
    
}
