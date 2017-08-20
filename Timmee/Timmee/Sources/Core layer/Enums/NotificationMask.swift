//
//  NotificationMask.swift
//  Timmee
//
//  Created by Ilya Kharabet on 20.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

enum NotificationMask: Int16 {
    case doNotNotify = 0
    case till10minutes = 1
    case till30minutes = 2
    case till1hour = 3
    case till2hours = 4
    case till6hours = 5
    case till12hours = 6
    case till1day = 7
    
    init(mask: Int16) {
        switch mask {
        case 1: self = .till10minutes
        case 2: self = .till30minutes
        case 3: self = .till1hour
        case 4: self = .till2hours
        case 5: self = .till6hours
        case 6: self = .till12hours
        case 7: self = .till1day
        default: self = .doNotNotify
        }
    }
}

extension NotificationMask {

    var title: String {
        switch self {
        case .doNotNotify: return ""
        case .till10minutes: return ""
        case .till30minutes: return ""
        case .till1hour: return ""
        case .till2hours: return ""
        case .till6hours: return ""
        case .till12hours: return ""
        case .till1day: return ""
        }
    }

}
