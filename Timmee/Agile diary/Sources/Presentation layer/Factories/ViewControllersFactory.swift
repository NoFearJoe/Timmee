//
//  ViewControllersFactory.swift
//  Agile diary
//
//  Created by i.kharabet on 13.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import class MessageUI.MFMailComposeViewController

final class ViewControllersFactory {
    
    static var sprintCreation: SprintCreationViewController {
        return UIStoryboard(name: "SprintCreation", bundle: nil).instantiateInitialViewController() as! SprintCreationViewController
    }
    
    static var notificationTimePicker: NotificationTimePicker {
        return UIStoryboard(name: "SprintCreation", bundle: nil).instantiateViewController(withIdentifier: "NotificationTimePicker") as! NotificationTimePicker
    }
    
    static var editorContainer: EditorContainer {
        return UIStoryboard(name: "SprintCreation", bundle: nil).instantiateViewController(withIdentifier: "EditorContainer") as! EditorContainer
    }
    
    static var dueDatePicker: DueDatePicker {
        return UIStoryboard(name: "SprintCreation", bundle: nil).instantiateViewController(withIdentifier: "DueDatePicker") as! DueDatePicker
    }
    
    static var today: TodayViewController {
        return UIStoryboard(name: "Today", bundle: nil).instantiateInitialViewController() as! TodayViewController
    }
    
    // Authorization
    
    static var pinCreation: PinCreationViewController {
        return UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "PinCreation") as! PinCreationViewController
    }
    
    static var pinAuthentication: PinAuthenticationViewController {
        return UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "PinAuthentication") as! PinAuthenticationViewController
    }
    
    static var biometricsActivation: BiometricsActivationController {
        return UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "BiometricsActivation") as! BiometricsActivationController
    }
    
    // Education
    
    static var education: EducationViewController {
        return UIStoryboard(name: "Education", bundle: nil).instantiateInitialViewController() as! EducationViewController
    }
    
    static var initialEducationScreen: InitialEducationScreen {
        return UIStoryboard(name: "Education", bundle: nil).instantiateViewController(withIdentifier: "InitialEducationScreen") as! InitialEducationScreen
    }
    
    static var targetsEducationScreen: TargetsEducationScreen {
        return UIStoryboard(name: "Education", bundle: nil).instantiateViewController(withIdentifier: "TargetsEducationScreen") as! TargetsEducationScreen
    }
    
    static var habitsEducationScreen: HabitsEducationScreen {
        return UIStoryboard(name: "Education", bundle: nil).instantiateViewController(withIdentifier: "HabitsEducationScreen") as! HabitsEducationScreen
    }
    
    static var notificationsSetupSuggestionScreen: NotificationsSetupSuggestionScreen {
        return UIStoryboard(name: "Education", bundle: nil).instantiateViewController(withIdentifier: "NotificationsSetupSuggestionScreen") as! NotificationsSetupSuggestionScreen
    }
    
    static var pinCodeSetupSuggestionEducationScreen: PinCodeSetupSuggestionEducationScreen {
        return UIStoryboard(name: "Education", bundle: nil).instantiateViewController(withIdentifier: "PinCodeSetupSuggestionEducationScreen") as! PinCodeSetupSuggestionEducationScreen
    }
    
    static var finalEducationScreen: FinalEducationScreen {
        return UIStoryboard(name: "Education", bundle: nil).instantiateViewController(withIdentifier: "FinalEducationScreen") as! FinalEducationScreen
    }
    
    // Other
    
    static var mail: MFMailComposeViewController {
        let viewController = MFMailComposeViewController()
        if #available(iOS 11.0, *) {
            viewController.setPreferredSendingEmailAddress("mesterra.co@gmail.com")
        }
        viewController.setToRecipients(["mesterra.co@gmail.com"])
        return viewController
    }
    
}
