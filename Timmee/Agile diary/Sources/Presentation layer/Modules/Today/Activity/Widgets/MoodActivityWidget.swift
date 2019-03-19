//
//  MoodActivityWidget.swift
//  Agile diary
//
//  Created by i.kharabet on 18.03.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import TasksKit

final class MoodActivityWidget: UIViewController {
    
    private let moodService = ServicesAssembly.shared.moodServce
    
    @IBOutlet private var moodButtons: [UIButton]!
    
    @IBAction private func onTapToMoodButton(_ button: UIButton) {
        guard let selectedMoodKind = Mood.Kind.allCases.item(at: button.tag) else { return }
        let mood = Mood(kind: selectedMoodKind, date: Date.now.startOfDay)
        moodService.createOrUpdateMood(mood, completion: nil)
    }
    
}

extension MoodActivityWidget: ActivityWidget {
    
    func refresh() {
        if let todayMood = getTodayMood() {
            
        } else {
            
        }
    }
    
}

extension MoodActivityWidget: StaticHeightStackChidController {
    
    var height: CGFloat {
        return 156
    }
    
}

private extension MoodActivityWidget {
    
    func getTodayMood() -> Mood? {
        return moodService.fetchMood(date: Date.now.startOfDay)
    }
    
}
