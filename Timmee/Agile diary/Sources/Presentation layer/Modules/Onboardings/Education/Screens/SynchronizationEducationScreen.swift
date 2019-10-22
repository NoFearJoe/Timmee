//
//  SynchronizationEducationScreen.swift
//  Agile diary
//
//  Created by i.kharabet on 22/10/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class SynchronizationEducationScreen: BaseViewController {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var activityIndicator: LoadingView!
    
    private var output: EducationScreenOutput!
    
    override func prepare() {
        super.prepare()
        
        titleLabel.text = "education_sync_title".localized
        textLabel.text = "education_sync_text".localized
        
        activityIndicator.isHidden = false
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        textLabel.textColor = AppTheme.current.colors.inactiveElementColor
        activityIndicator.tintColor = AppTheme.current.colors.mainElementColor
        activityIndicator.backgroundColor = .clear
    }
    
}

extension SynchronizationEducationScreen: EducationScreenInput {
    
    func setupOutput(_ output: EducationScreenOutput) {
        self.output = output
    }
    
}
