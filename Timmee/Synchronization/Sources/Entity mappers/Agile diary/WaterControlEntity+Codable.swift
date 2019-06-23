//
//  WaterControlEntity+Codable.swift
//  Synchronization
//
//  Created by i.kharabet on 23.01.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import TasksKit
import Firebase

extension WaterControlEntity: DictionaryEncodable {
    
    func encode() -> [String : Any] {
        let requiredFields = [
            "id": (id ?? WaterControl.defaultID) as Any,
            "neededVolume": neededVolume,
            "notificationsEnabled": notificationsEnabled,
            "sprintID": (sprint?.id ?? "") as Any,
            "modificationDate": modificationDate,
            "gender": gender,
            "activity": activity,
            "weight": weight
        ]
        
        var optionalFields: [String: Any] = [:]
        
        notificationsStartTime.map { optionalFields["notificationsStartTime"] = $0 }
        notificationsEndTime.map { optionalFields["notificationsEndTime"] = $0 }
        drunkVolumes.map { drunkVolumes in
            guard let drunkVolumes = drunkVolumes as? [Date: Int] else { return }
            var drunkVolumesDictionary: [String: Int] = [:]
            drunkVolumes.forEach { date, volume in
                drunkVolumesDictionary[date.asDateTimeString] = volume
            }
            optionalFields["drunkVolumes"] = drunkVolumesDictionary
        }
        
        return requiredFields.merging(optionalFields, uniquingKeysWith: { old, new in new })
    }
    
}

extension WaterControlEntity: DictionaryDecodable {
    
    func decode(_ dictionary: [String : Any]) {
        id = dictionary["id"] as? String ?? WaterControl.defaultID
        neededVolume = dictionary["neededVolume"] as? Int32 ?? 0
        notificationsEnabled = dictionary["notificationsEnabled"] as? Bool ?? false
        notificationsStartTime = (dictionary["notificationsStartTime"] as? Timestamp)?.dateValue()
        notificationsEndTime = (dictionary["notificationsEndTime"] as? Timestamp)?.dateValue()
        modificationDate = dictionary["modificationDate"] as? TimeInterval ?? 0
        weight = dictionary["weight"] as? Double ?? 65
        gender = dictionary["gender"] as? Int16 ?? 0
        activity = dictionary["activity"] as? Int16 ?? 1
        
        let drunkVolumesDictionary = dictionary["drunkVolumes"] as? [String: Any]
        var drunkVolumes: [Date: Int] = [:]
        drunkVolumesDictionary?.forEach { dateString, volume in
            guard let date = Date(string: dateString, format: Date.dateTimeFormat) else { return }
            guard let volume = volume as? Int else { return }
            drunkVolumes[date] = volume
        }
        self.drunkVolumes = drunkVolumes as NSDictionary
    }
    
}
