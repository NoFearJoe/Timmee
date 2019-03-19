//
//  Mood.swift
//  TasksKit
//
//  Created by i.kharabet on 19.03.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import struct Foundation.Date

public final class Mood {
    
    public enum Kind: String {
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
