//
//  DiaryEntryEntity+Codable.swift
//  Synchronization
//
//  Created by i.kharabet on 30/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import TasksKit

extension DiaryEntryEntity: DictionaryEncodable {
    
    func encode() -> [String : Any] {
        return [
            "id": id as Any,
            "text": text as Any,
            "date": date as Any,
            "attachment": attachment as Any,
            "modificationDate": modificationDate
        ]
    }
    
}

extension DiaryEntryEntity: DictionaryDecodable {
    
    func decode(_ dictionary: [String : Any]) {
        id = dictionary["id"] as? String
        text = dictionary["text"] as? String
        date = (dictionary["date"] as? FirebaseFirestoreTimestampProtocol)?.dateValue()
        attachment = dictionary["attachment"] as? String
        modificationDate = dictionary["modificationDate"] as? TimeInterval ?? 0
    }
    
}
