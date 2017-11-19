//
//  NearestDate.swift
//  Timmee
//
//  Created by Ilya Kharabet on 19.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date

enum NearestDate {
    case yeasterday
    case today
    case tomorrow
    case custom(date: Date)
    
    init(date: Date) {
        switch date {
        case let date where date.isWithinSameDay(of: Date() - 1.asDays):
            self = .yeasterday
        case let date where date.isWithinSameDay(of: Date()):
            self = .today
        case let date where date.isWithinSameDay(of: Date() + 1.asDays):
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
        case .yeasterday: return Date() - 1.asDays
        case .today: return Date()
        case .tomorrow: return Date() + 1.asDays
        case .custom(let date): return date
        }
    }
    
}
