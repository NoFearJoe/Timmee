//
//  Date+Today.swift
//  Agile diary
//
//  Created by i.kharabet on 25.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import struct Foundation.Date
import Workset

public struct DayOffset {
    public static let shared = DayOffset()
    
    public var current: Int = 0
}

public extension Date {
    
    static var now: Date {
        #if DEBUG
        return Date() + DayOffset.shared.current.asDays
        #else
        return Date()
        #endif
    }
    
}
