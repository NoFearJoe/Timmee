//
//  Gender.swift
//  TasksKit
//
//  Created by Илья Харабет on 23/06/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

public typealias Milliliters = Int

public enum Gender: Int {
    case male = 0
    case female
    
    public var title: String {
        switch self {
        case .male: return "male".localized
        case .female: return "female".localized
        }
    }
    
    public var waterVolumePerKilogram: Milliliters {
        switch self {
        case .male: return 40
        case .female: return 30
        }
    }
    
    public var waterVolumePerTrainingHour: Milliliters {
        switch self {
        case .male: return 600
        case .female: return 400
        }
    }
}
