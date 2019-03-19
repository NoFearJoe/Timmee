//
//  Mood+Codable.swift
//  Synchronization
//
//  Created by i.kharabet on 19.03.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import TasksKit
import Firebase

extension MoodEntity: DictionaryEncodable {
    
    func encode() -> [String : Any] {
        return [
            "mood": mood ?? "",
            "date": date?.asDateTimeString ?? ""
        ]
    }
    
}

extension MoodEntity: DictionaryDecodable {
    
    func decode(_ dictionary: [String : Any]) {
        mood = dictionary["mood"] as? String ?? ""
        date = (dictionary["date"] as? String).flatMap { Date(string: $0, format: Date.dateTimeFormat) } ?? Date()
    }
    
}
