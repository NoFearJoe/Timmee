//
//  NearestDate.swift
//  Timmee
//
//  Created by Ilya Kharabet on 19.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date
import class Foundation.NSDate
import MTDates

enum NearestDate {
    case yeasterday
    case today
    case tomorrow
    case custom(date: Date)
    
    init(date: Date) {
        let nsDate = date as NSDate
        switch nsDate {
        case let date where date.mt_is(withinSameDay: NSDate().mt_dateDays(before: 1)):
            self = .yeasterday
        case let date where date.mt_is(withinSameDay: Date()):
            self = .today
        case let date where date.mt_is(withinSameDay: NSDate().mt_dateDays(after: 1)):
            self = .tomorrow
        default:
            self = .custom(date: date)
        }
    }
    
    var title: String {
        switch self {
        case .yeasterday: return "yesterday".localized
        case .today: return "today".localized
        case .tomorrow: return "tomorrow".localized
        case .custom(let date): return date.asDayMonthTime
        }
    }
    
    var date: Date {
        switch self {
        case .yeasterday: return NSDate().mt_dateDays(before: 1)
        case .today: return Date()
        case .tomorrow: return NSDate().mt_dateDays(after: 1)
        case .custom(let date): return date
        }
    }
    
}
