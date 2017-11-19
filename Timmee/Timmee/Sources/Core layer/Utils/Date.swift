//
//  Date.swift
//  Timmee
//
//  Created by Ilya Kharabet on 19.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date
import class Foundation.NSDate

extension Date {
    
    /// Формат даты, используемый в приложении
    static let dateFormat = "dd-MM-yyyy"
    
    var asMonth: String {
        return asString(format: "MMMM", localized: true)
    }
    
    var asDayMonth: String {
        return asString(format: "d MMMM")
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
        return asString(format: "dd.MM.yyyy HH:mm")
    }
    
    var asTimeString: String {
        return asString(format: "HH:mm")
    }
    
}

extension Date {

    var nsDate: NSDate {
        return self as NSDate
    }

}
