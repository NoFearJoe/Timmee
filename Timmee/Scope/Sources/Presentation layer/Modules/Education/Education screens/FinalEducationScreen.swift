//
//  FinalEducationScreen.swift
//  Timmee
//
//  Created by i.kharabet on 16.01.18.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class FinalEducationScreen: UIViewController {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    
    @IBOutlet private var continueButton: UIButton!
    
    @IBAction func continueEducation() {
        output.didAskToContinueEducation(screen: .final)
    }
    
    private var output: EducationScreenOutput!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "education_final_title".localized
        textLabel.text = "education_final_text".localized
        
        continueButton.setTitle("education_final_continue".localized, for: .normal)
        
        continueButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.blueColor), for: .normal)
    }
    
}

extension FinalEducationScreen: EducationScreenInput {
    
    func setupOutput(_ output: EducationScreenOutput) {
        self.output = output
    }
    
}
