//
//  Date.swift
//  Timmee
//
//  Created by Ilya Kharabet on 19.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date
import class Foundation.NSDate

public extension Date {
    
    /// Формат даты, используемый в приложении
    public static let dateFormat = "dd-MM-yyyy"
    
    public var asMonth: String {
        return asString(format: "MMMM", localized: true)
    }
    
    public var asDayMonth: String {
        return asString(format: "d MMMM")
    }
    
    public var asDayMonthYear: String {
        return asString(format: "d MMMM YYYY")
    }
    
    public var asDayMonthTime: String {
        return asString(format: "d MMMM, HH:mm")
    }
    
    public var asShortWeekday: String {
        return asString(format: "E")
    }
    
    public var asDateTimeString: String {
        return asString(format: "dd.MM.yyyy HH:mm")
    }
    
    public var asTimeString: String {
        return asString(format: "HH:mm")
    }
    
    public var asNearestDateString: String {
        let nearestDate = NearestDate(date: self)
        
        if case .custom = nearestDate {
            return self.asDayMonthTime
        } else {
            return nearestDate.title + ", " + self.asTimeString
        }
    }
    
    public var asNearestShortDateString: String {
        let nearestDate = NearestDate(date: self)
        
        if case .custom = nearestDate {
            return self.asDayMonth
        } else {
            return nearestDate.title
        }
    }
    
}

public extension Date {

    public var nsDate: NSDate {
        return self as NSDate
    }

}
