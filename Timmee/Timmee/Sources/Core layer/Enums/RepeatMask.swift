//
//  RepeatMask.swift
//  Timmee
//
//  Created by Ilya Kharabet on 20.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

enum RepeatMask {
    case noRepeat
    case everyHour
    case everyDay
    case everyWeek
    case everyTwoWeeks
    case everyMonth
    case everyWorkDay
    case everyHoliday
    case custom
}

extension RepeatMask {

    var title: String {
        switch self {
        case .noRepeat: return ""
        case .everyHour: return ""
        case .everyDay: return ""
        case .everyWeek: return ""
        case .everyTwoWeeks: return ""
        case .everyMonth: return ""
        case .everyWorkDay: return ""
        case .everyHoliday: return ""
        case .custom: return ""
        }
    }

}
