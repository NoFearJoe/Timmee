//
//  TimeRounder.swift
//  Timmee
//
//  Created by i.kharabet on 20.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date

public struct TimeRounder {
    
    public static func roundMinutes(_ minutes: Int) -> Int {
        let reminder = Double(minutes).truncatingRemainder(dividingBy: 5)
        
        var roundedMinutes: Int
        if reminder < 3 {
            roundedMinutes = minutes - Int(reminder)
        } else {
            roundedMinutes = minutes - Int(reminder) + 5
        }
        
        // Rounded minute should be greather than minute
        if roundedMinutes < minutes {
            roundedMinutes += 5
        }
        
        let minutes = min(60, max(0, roundedMinutes))
        
        return minutes == 60 ? 0 : minutes
    }
    
}
