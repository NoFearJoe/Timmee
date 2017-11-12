//
//  Date.swift
//  Timmee
//
//  Created by Ilya Kharabet on 19.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date
import class Foundation.NSDate
import MTDates


extension Date {
    
    /// Формат даты, используемый в приложении
    static let dateFormat = "dd-MM-yyyy"
    
    var asMonth: String {
        return dateString(with: "MMMM", localized: true)
    }
    
    var asDayMonth: String {
        return dateString(with: "d MMMM")
    }
    
    var asDayMonthYear: String {
        return dateString(with: "d MMMM YYYY")
    }
    
    var asDayMonthTime: String {
        return dateString(with: "d MMMM, HH:mm")
    }
    
    fileprivate func dateString(with format: String, localized: Bool = false) -> String {
        return nsDate.mt_stringFromDate(withFormat: format, localized: localized)
    }
    
    /**
     Преобразует дату в строку в соответствии с форматом
     
     - Parameter date: Дата которая будет преобразована
     
     - Returns: Строка
     */
    static func apiString(from date: Date) -> String? {
        return date.nsDate.mt_stringFromDate(withFormat: Date.dateFormat, localized: false)
    }
    
    /**
     Преобразует строку в дату в соответствии с форматом
     
     - Parameter string: Строка, содержащая дату
     
     - Returns: Дата или nil
     */
    static func apiDate(from string: String) -> Date? {
        return NSDate.mt_date(from: string, usingFormat: Date.dateFormat)
    }
    
    
    var asDateTimeString: String {
        return nsDate.mt_stringFromDate(withFormat: "dd.MM.yyyy HH:mm", localized: false)
    }
    
    var asTimeString: String {
        return nsDate.mt_stringFromDate(withFormat: "HH:mm", localized: false)
    }
    
}

extension Date {

    var nsDate: NSDate {
        return self as NSDate
    }

}

extension Date {

    static var startOfNextHour: Date {
        return Date().nsDate.mt_startOfNextHour()
    }

}
