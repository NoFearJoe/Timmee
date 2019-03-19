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
        
    }
    
}

extension MoodActivityWidget: ActivityWidget {
    
    func refresh() {
        
    }
    
}

extension MoodActivityWidget: StaticHeightStackChidController {
    
    var height: CGFloat {
        return 156
    }
    
}
