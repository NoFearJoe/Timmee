//
//  Time.swift
//  TasksKit
//
//  Created by Илья Харабет on 05/06/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation
import Workset

public struct Time {
    public let hours: Int
    public let minutes: Int
    
    public init(_ hours: Int, _ minutes: Int) {
        self.hours = hours
        self.minutes = minutes
    }
    
    public init?(string: String) {
        let components = string.split(separator: ":")
        guard
            let hours = components.item(at: 0).flatMap({ Int($0) }),
            let minutes = components.item(at: 1).flatMap({ Int($0) })
        else {
            return nil
        }
        
        self.hours = hours
        self.minutes = minutes
    }
    
    public var string: String {
        let minutes: String = {
            if self.minutes < 10 {
                return "0\(self.minutes)"
            } else {
                return "\(self.minutes)"
            }
        }()
        
        return "\(hours):\(minutes)"
    }
}

extension Time: Equatable {
    
    public static func == (lhs: Time, rhs: Time) -> Bool {
        lhs.hours == rhs.hours && lhs.minutes == rhs.minutes
    }
    
}

extension Time: Comparable {
    
    public static func < (lhs: Time, rhs: Time) -> Bool {
        lhs.hours < rhs.hours
            || lhs.hours == rhs.hours && lhs.minutes < rhs.minutes
    }
    
}

extension Array where Element == Time {
    
    public var readableString: String {
        map { $0.string }.joined(separator: ", ")
    }
    
}

public func - (lhs: Time, rhs: Minutes) -> Time {
    if lhs.minutes < rhs.value {
        let diff = lhs.minutes - rhs.value
        let hours = Int(ceil(Double(abs(diff)) / 60.0))
        
        if lhs.hours - hours < 0 {
            return Time(0, 0)
        } else {
            let minutes = diff == 0 ? 0 : 60 + (diff % 60)
            return Time(lhs.hours - hours, minutes)
        }
    } else {
        return Time(lhs.hours, lhs.minutes - rhs.value)
    }
}
