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
    
    public static let dateTimeFormat = "dd.MM.yyyy HH:mm"
    
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
        return asString(format: Date.dateTimeFormat)
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
    
    public init?(string: String, format: String, localized: Bool = false) {
        let formatter = DateFormatter()
        if localized {
            formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: format, options: 0, locale: Locale.current)
        } else {
            formatter.dateFormat = format
        }
        
        guard let date = formatter.date(from: string) else { return nil }
        
        self = date
    }
    
}

public extension Date {

    public var nsDate: NSDate {
        return self as NSDate
    }

}
