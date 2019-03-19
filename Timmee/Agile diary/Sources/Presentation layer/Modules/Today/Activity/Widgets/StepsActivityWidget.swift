//
//  StepsActivityWidget.swift
//  Agile diary
//
//  Created by i.kharabet on 18.03.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import TasksKit

final class StepsActivityWidget: UIViewController {
    
    
    
}

extension StepsActivityWidget: ActivityWidget {
    
    func refresh() {
        
    }
    
}

extension StepsActivityWidget: StaticHeightStackChidController {
    
    var height: CGFloat {
        return 212
    }
    
}
