//
//  InitialEducationScreen.swift
//  Timmee
//
//  Created by Илья Харабет on 13.01.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class InitialEducationScreen: UIViewController {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    
    @IBOutlet private var continueButton: UIButton!
    
    @IBAction func continueEducation() {
        output.didAskToContinueEducation(screen: .initial)
    }
    
    private weak var output: EducationScreenOutput!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "education_initial_title".localized
        textLabel.text = "education_initial_text".localized
        
        continueButton.setTitle("education_initial_continue".localized, for: .normal)
        continueButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.blueColor), for: .normal)
    }
    
}

extension InitialEducationScreen: EducationScreenInput {
    
    func setupOutput(_ output: EducationScreenOutput) {
        self.output = output
    }
    
}
