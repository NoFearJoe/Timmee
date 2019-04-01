//
//  TrackersConfigurator.swift
//  Agile diary
//
//  Created by i.kharabet on 01/04/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import Workset

final class TrackersConfigurator {
    
    static let shared = TrackersConfigurator()
    
    lazy var showProVersionTracker: Tracker? = Tracker.obtain(for: "show_pro_version_tracker")
    
    init() {
        Tracker.register(with: "show_pro_version_tracker", condition: TrackerCondition.quadratic(3))
    }
    
}
