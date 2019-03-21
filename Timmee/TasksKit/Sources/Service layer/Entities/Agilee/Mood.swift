//
//  Mood.swift
//  TasksKit
//
//  Created by i.kharabet on 19.03.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import struct Foundation.Date

public final class Mood {
    
    public enum Kind: String, CaseIterable {
        case veryBad, bad, normal, good, veryGood
    }
    
    public var kind: Kind
    public var date: Date
    
    public init(kind: Kind, date: Date) {
        self.kind = kind
        self.date = date
    }
    
    public init(entity: MoodEntity) {
        kind = entity.mood.flatMap(Kind.init(rawValue:)) ?? .normal
        date = entity.date ?? Date()
    }
    
}

extension Mood.Kind {
    
    public var localized: String {
        switch self {
        case .veryBad: return "very_bad_mood".localized
        case .bad: return "bad_mood".localized
        case .normal: return "normal_mood".localized
        case .good: return "good_mood".localized
        case .veryGood: return "very_good_mood".localized
        }
    }
    
    public var icon: String {
        switch self {
        case .veryBad: return "veryBad"
        case .bad: return "bad"
        case .normal: return "normal"
        case .good: return "good"
        case .veryGood: return "veryGood"
        }
    }
    
    public var color: UIColor {
        switch self {
        case .veryBad: return .red
        case .bad: return .magenta
        case .normal: return .yellow
        case .good: return .blue
        case .veryGood: return .green
        }
    }
    
    public var value: Int {
        switch self {
        case .veryBad: return -2
        case .bad: return -1
        case .normal: return 0
        case .good: return 1
        case .veryGood: return 2
        }
    }
    
    public init(value: Int) {
        switch value {
        case ...(-2): self = .veryBad
        case -1: self = .bad
        case 0: self = .normal
        case 1: self = .good
        case 2...: self = .veryGood
        default: self = .normal
        }
    }
    
}
