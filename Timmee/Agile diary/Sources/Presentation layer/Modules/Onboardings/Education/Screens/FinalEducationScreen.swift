//
//  FinalEducationScreen.swift
//  Agile diary
//
//  Created by i.kharabet on 17.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class FinalEducationScreen: BaseViewController {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    
    @IBOutlet private var continueButton: UIButton!
    
    @IBAction func continueEducation() {
        output.didAskToContinueEducation(screen: .final)
    }
    
    private var output: EducationScreenOutput!
    
    override func prepare() {
        super.prepare()
        
        titleLabel.text = "education_final_title".localized
        textLabel.text = "education_final_text".localized
        
        continueButton.setTitle("education_final_continue".localized, for: .normal)
        
        setupAppearance()
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        textLabel.textColor = AppTheme.current.colors.inactiveElementColor
        
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
    }
    
}

extension FinalEducationScreen: EducationScreenInput {
    
    func setupOutput(_ output: EducationScreenOutput) {
        self.output = output
    }
    
}
