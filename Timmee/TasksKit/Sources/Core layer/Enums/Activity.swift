//
//  Activity.swift
//  TasksKit
//
//  Created by Илья Харабет on 23/06/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import Workset

public enum Activity: Int {
    case low = 0
    case medium
    case high
    
    public var title: String {
        switch self {
        case .low: return "activity_low".localized
        case .medium: return "activity_medium".localized
        case .high: return "activity_high".localized
        }
    }
    
    public var averageTrainingHoursPerDay: Double {
        switch self {
        case .low: return 1 / 7
        case .medium: return 3 / 7
        case .high: return 6 / 7
        }
    }
}
