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
    
    // Sprints
    
    static var notificationTimePicker: NotificationTimePicker {
        UIStoryboard(name: "SprintCreation", bundle: nil).instantiateViewController(withIdentifier: "NotificationTimePicker") as! NotificationTimePicker
    }
    
    static var editorContainer: EditorContainer {
        UIStoryboard(name: "SprintCreation", bundle: nil).instantiateViewController(withIdentifier: "EditorContainer") as! EditorContainer
    }
    
    static var dueDatePicker: DueDatePicker {
        UIStoryboard(name: "SprintCreation", bundle: nil).instantiateViewController(withIdentifier: "DueDatePicker") as! DueDatePicker
    }
    
    static var sprintNotificationTimePicker: SprintNotificationTimePicker {
        UIStoryboard(name: "SprintCreation", bundle: nil).instantiateViewController(withIdentifier: "SprintNotificationTimePicker") as! SprintNotificationTimePicker
    }
    
    static var sprintDurationPicker: SprintDurationPicker {
        UIStoryboard(name: "SprintCreation", bundle: nil).instantiateViewController(withIdentifier: "SprintDurationPicker") as! SprintDurationPicker
    }
    
    static var habitEditor: HabitCreationViewController {
        UIStoryboard(name: "SprintCreation", bundle: nil).instantiateViewController(withIdentifier: "HabitCreationViewController") as! HabitCreationViewController
    }
    
    static var goalEditor: GoalCreationViewController {
        UIStoryboard(name: "SprintCreation", bundle: nil).instantiateViewController(withIdentifier: "TargetCreationViewController") as! GoalCreationViewController
    }
    
    static var habitsCollectionViewController: HabitsCollectionViewController {
        UIStoryboard(name: "HabitsCollection", bundle: nil).instantiateViewController(withIdentifier: "HabitsCollection") as! HabitsCollectionViewController
    }
    
    // Today
    
    static var today: TodayViewController {
        UIStoryboard(name: "Today", bundle: nil).instantiateInitialViewController() as! TodayViewController
    }
    
    // Authorization
    
    static var authorization: AuthorizationViewController {
        UIStoryboard(name: "Authorization", bundle: nil).instantiateInitialViewController() as! AuthorizationViewController
    }
    
    static var recoverPassword: AuthorizationViewController {
        UIStoryboard(name: "Authorization", bundle: nil).instantiateViewController(withIdentifier: "RecoverPassword") as! AuthorizationViewController
    }
    
    static var pinCreation: PinCreationViewController {
        UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "PinCreation") as! PinCreationViewController
    }
    
    static var pinAuthentication: PinAuthenticationViewController {
        UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "PinAuthentication") as! PinAuthenticationViewController
    }
    
    static var biometricsActivation: BiometricsActivationController {
        UIStoryboard(name: "Authentication", bundle: nil).instantiateViewController(withIdentifier: "BiometricsActivation") as! BiometricsActivationController
    }
    
    // Education
    
    static var education: EducationViewController {
        UIStoryboard(name: "Education", bundle: nil).instantiateInitialViewController() as! EducationViewController
    }
    
    static var initialEducationScreen: InitialEducationScreen {
        UIStoryboard(name: "Education", bundle: nil).instantiateViewController(withIdentifier: "InitialEducationScreen") as! InitialEducationScreen
    }
    
    static var immutableSprintsEducationScreen: ImmutableSprintsEducationScreen {
        UIStoryboard(name: "Education", bundle: nil).instantiateViewController(withIdentifier: "ImmutableSprintsEducationScreen") as! ImmutableSprintsEducationScreen
    }
    
    static var notificationsSetupSuggestionScreen: NotificationsSetupSuggestionScreen {
        UIStoryboard(name: "Education", bundle: nil).instantiateViewController(withIdentifier: "NotificationsSetupSuggestionScreen") as! NotificationsSetupSuggestionScreen
    }
    
    static var pinCodeSetupSuggestionEducationScreen: PinCodeSetupSuggestionEducationScreen {
        UIStoryboard(name: "Education", bundle: nil).instantiateViewController(withIdentifier: "PinCodeSetupSuggestionEducationScreen") as! PinCodeSetupSuggestionEducationScreen
    }
    
    static var proVersionEducationScreen: ProVersionEducationScreen {
        UIStoryboard(name: "Education", bundle: nil).instantiateViewController(withIdentifier: "ProVersionEducationScreen") as! ProVersionEducationScreen
    }
    
    static var synchronizationEducationScreen: SynchronizationEducationScreen {
        UIStoryboard(name: "Education", bundle: nil).instantiateViewController(withIdentifier: "SynchronizationEducationScreen") as! SynchronizationEducationScreen
    }
    
    static var finalEducationScreen: FinalEducationScreen {
        UIStoryboard(name: "Education", bundle: nil).instantiateViewController(withIdentifier: "FinalEducationScreen") as! FinalEducationScreen
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
    
    static var preInitialScreen: PreInitialScreenViewController {
        PreInitialScreenViewController()
    }
    
}
