//
//  Trackers.swift
//  Timmee
//
//  Created by Илья Харабет on 12.05.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

struct Trackers {
    
    private static let appLaunchTrackerKey = "app_launch"
    static let appLaunchTracker = Tracker.obtain(for: appLaunchTrackerKey)
    static func registerAppLaunchTracker() {
        Tracker.register(with: appLaunchTrackerKey, condition: .quadratic(3))
    }
    
}
