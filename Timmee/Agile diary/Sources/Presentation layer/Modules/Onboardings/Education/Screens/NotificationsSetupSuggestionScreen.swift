//
//  NotificationsSetupSuggestionScreen.swift
//  Agile diary
//
//  Created by i.kharabet on 17.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class NotificationsSetupSuggestionScreen: UIViewController {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    
    @IBOutlet private var continueButton: UIButton!
    @IBOutlet private var skipButton: UIButton!
    
    @IBAction func continueEducation() {
        NotificationsConfigurator.registerForLocalNotifications(application: UIApplication.shared, completion: { _ in
            self.output.didAskToContinueEducation(screen: .notificationsSetupSuggestion)
        })
    }
    
    @IBAction func skipEducation() {
        output.didAskToSkipEducation(screen: .notificationsSetupSuggestion)
    }
    
    private var output: EducationScreenOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "education_notifications_setup_title".localized
        textLabel.text = "education_notifications_setup_text".localized
        
        continueButton.setTitle("education_notifications_setup_continue".localized, for: .normal)
        skipButton.setTitle("education_notifications_setup_skip".localized, for: .normal)
        
        setupAppearance()
    }
    
    private func setupAppearance() {
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        textLabel.textColor = AppTheme.current.colors.inactiveElementColor
        
        continueButton.setTitleColor(.white, for: .normal)
        skipButton.setTitleColor(AppTheme.current.colors.inactiveElementColor, for: .normal)
        
        continueButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        skipButton.backgroundColor = .clear
    }
    
}

extension NotificationsSetupSuggestionScreen: EducationScreenInput {
    
    func setupOutput(_ output: EducationScreenOutput) {
        self.output = output
    }
    
}
