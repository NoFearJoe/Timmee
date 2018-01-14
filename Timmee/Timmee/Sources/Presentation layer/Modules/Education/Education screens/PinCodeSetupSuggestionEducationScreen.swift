//
//  PinCodeSetupSuggestionEducationScreen.swift
//  Timmee
//
//  Created by Илья Харабет on 13.01.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class PinCodeSetupSuggestionEducationScreen: UIViewController {
    
    @IBOutlet private var continueButton: UIButton!
    @IBOutlet private var skipButton: UIButton!
    
    @IBAction func continueEducation() {
        output.didAskToContinueEducation(screen: .pinCodeSetupSuggestion)
    }
    
    @IBAction func skipEducation() {
        output.didAskToSkipEducation(screen: .pinCodeSetupSuggestion)
    }
    
    private var output: EducationScreenOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        continueButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.blueColor), for: .normal)
        skipButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.secondaryBackgroundTintColor), for: .normal)
    }
    
}

extension PinCodeSetupSuggestionEducationScreen: EducationScreenInput {
    
    func setupOutput(_ output: EducationScreenOutput) {
        self.output = output
    }
    
}
