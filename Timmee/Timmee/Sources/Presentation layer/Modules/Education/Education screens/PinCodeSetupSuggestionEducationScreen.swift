//
//  PinCodeSetupSuggestionEducationScreen.swift
//  Timmee
//
//  Created by Илья Харабет on 13.01.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class PinCodeSetupSuggestionEducationScreen: UIViewController {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    
    @IBOutlet private var continueButton: UIButton!
    @IBOutlet private var skipButton: UIButton!
    
    @IBAction func continueEducation() {
        output.didAskToContinueEducation(screen: .pinCodeSetupSuggestion)
    }
    
    @IBAction func skipEducation() {
        output.didAskToSkipEducation(screen: .pinCodeSetupSuggestion)
    }
    
    private var output: EducationScreenOutput!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "education_pin_setup_title".localized
        textLabel.text = "education_pin_setup_text".localized
        
        continueButton.setTitle("education_pin_setup_continue".localized, for: .normal)
        skipButton.setTitle("education_pin_setup_skip".localized, for: .normal)
        
        continueButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.blueColor), for: .normal)
        skipButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.secondaryBackgroundTintColor), for: .normal)
    }
    
}

extension PinCodeSetupSuggestionEducationScreen: EducationScreenInput {
    
    func setupOutput(_ output: EducationScreenOutput) {
        self.output = output
    }
    
}
