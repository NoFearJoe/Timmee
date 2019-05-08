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
    static let dateFormat = "dd-MM-yyyy"
    
    static let dateTimeFormat = "dd.MM.yyyy HH:mm"
    
    var asMonth: String {
        return asString(format: "MMMM", localized: true)
    }
    
    var asDayMonth: String {
        return asString(format: "d MMMM")
    }
    
    var asShortDayMonth: String {
        return asString(format: "d.MM")
    }
    
    var asDayMonthYear: String {
        return asString(format: "d MMMM YYYY")
    }
    
    var asDayMonthTime: String {
        return asString(format: "d MMMM, HH:mm")
    }
    
    var asShortWeekday: String {
        return asString(format: "E")
    }
    
    var asDateTimeString: String {
        return asString(format: Date.dateTimeFormat)
    }
    
    var asTimeString: String {
        return asString(format: "HH:mm")
    }
    
    var asNearestDateString: String {
        let nearestDate = NearestDate(date: self)
        
        if case .custom = nearestDate {
            return self.asDayMonthTime
        } else {
            return nearestDate.title + ", " + self.asTimeString
        }
    }
    
    var asNearestShortDateString: String {
        let nearestDate = NearestDate(date: self)
        
        if case .custom = nearestDate {
            return self.asDayMonth
        } else {
            return nearestDate.title
        }
    }
    
}

public extension Date {
    
    init?(string: String, format: String, localized: Bool = false) {
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

    var nsDate: NSDate {
        return self as NSDate
    }

}
