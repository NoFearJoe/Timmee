//
//  TodayViewSectionProgressListener.swift
//  Agile diary
//
//  Created by Илья Харабет on 04.07.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit

protocol TodayViewSectionProgressListener: AnyObject {
    func didChangeProgress(for section: SprintSection, to progress: CGFloat)
}
