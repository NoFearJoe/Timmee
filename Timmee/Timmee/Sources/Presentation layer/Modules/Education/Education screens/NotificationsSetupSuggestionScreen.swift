//
//  NotificationsSetupSuggestionScreen.swift
//  Timmee
//
//  Created by i.kharabet on 17.01.18.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class NotificationsSetupSuggestionScreen: UIViewController {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    
    @IBOutlet private var continueButton: UIButton!
    @IBOutlet private var skipButton: UIButton!
    
    @IBAction func continueEducation() {
        output.didAskToContinueEducation(screen: .notificationsSetupSuggestion)
        NotificationsConfigurator.registerForLocalNotifications(application: UIApplication.shared)
    }
    
    @IBAction func skipEducation() {
        output.didAskToSkipEducation(screen: .notificationsSetupSuggestion)
    }
    
    private var output: EducationScreenOutput!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "education_notifications_setup_title".localized
        textLabel.text = "education_notifications_setup_text".localized
        
        continueButton.setTitle("education_notifications_setup_continue".localized, for: .normal)
        skipButton.setTitle("education_notifications_setup_skip".localized, for: .normal)
        
        continueButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.blueColor), for: .normal)
        skipButton.backgroundColor = .clear
    }
    
}

extension NotificationsSetupSuggestionScreen: EducationScreenInput {
    
    func setupOutput(_ output: EducationScreenOutput) {
        self.output = output
    }
    
}
