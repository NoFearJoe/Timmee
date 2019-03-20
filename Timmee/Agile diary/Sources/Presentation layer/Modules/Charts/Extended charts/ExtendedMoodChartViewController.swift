//
//  ExtendedMoodChartViewController.swift
//  Agile diary
//
//  Created by Илья Харабет on 20/03/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class ExtendedMoodChartViewController: ExtendedChartViewController {
    
    private let moodService = ServicesAssembly.shared.moodServce
    
    override func prepare() {
        super.prepare()
        title = "mood".localized
    }
    
}
