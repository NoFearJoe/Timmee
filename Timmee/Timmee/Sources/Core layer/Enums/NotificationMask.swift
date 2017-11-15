//
//  NotificationMask.swift
//  Timmee
//
//  Created by Ilya Kharabet on 20.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

enum NotificationMask: Int16 {
    case doNotNotify = 0
    case justInTime = 1
    case till10minutes = 2
    case till30minutes = 3
    case till1hour = 4
    case till1day = 5
    
    static let all: [NotificationMask] = [.doNotNotify, .justInTime, .till10minutes, .till30minutes, .till1hour, .till1day]
    
    init(mask: Int16) {
        switch mask {
        case 1: self = .justInTime
        case 2: self = .till10minutes
        case 3: self = .till30minutes
        case 4: self = .till1hour
        case 5: self = .till1day
        default: self = .doNotNotify
        }
    }
}

extension NotificationMask {

    // TODO: Localize
    var title: String {
        switch self {
        case .doNotNotify: return "Не напоминать"
        case .justInTime: return "Напомнить точно в срок"
        case .till10minutes: return "Напомнить за 10 минут"
        case .till30minutes: return "Напомнить за 30 минут"
        case .till1hour: return "Напомнить за час"
        case .till1day: return "Напомнить за день"
        }
    }
    
    var minutes: Int {
        switch self {
        case .doNotNotify: return 0
        case .justInTime: return 0
        case .till10minutes: return 10
        case .till30minutes: return 30
        case .till1hour: return 60
        case .till1day: return 60 * 24
        }
    }

}
