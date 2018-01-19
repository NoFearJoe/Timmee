//
//  EducationViewController.swift
//  Timmee
//
//  Created by i.kharabet on 12.01.18.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

protocol EducationScreenInput: class {
    func setupOutput(_ output: EducationScreenOutput)
}

protocol EducationScreenOutput: class {
    func didAskToContinueEducation(screen: EducationScreen)
    func didAskToSkipEducation(screen: EducationScreen)
}

final class EducationViewController: UINavigationController {
    
    private let educationState = EducationState()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let initialScreen = educationState.screensToShow.first {
            setViewControllers([viewController(forScreen: initialScreen)], animated: false)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension EducationViewController: EducationScreenOutput {
    
    func didAskToContinueEducation(screen: EducationScreen) {
        if let screenIndex = educationState.screensToShow.index(of: screen) {
            if let nextScreen = educationState.screensToShow.item(at: screenIndex + 1) {
                pushViewController(viewController(forScreen: nextScreen), animated: true)
            } else {
                performSegue(withIdentifier: "ShowMainViewController", sender: nil)
            }
        } else {
            performSegue(withIdentifier: "ShowMainViewController", sender: nil)
        }
    }
    
    func didAskToSkipEducation(screen: EducationScreen) {
        switch screen {
        case .initial:
            didAskToContinueEducation(screen: .features)
        case .pinCodeSetupSuggestion:
            didAskToContinueEducation(screen: .pinCodeCreation)
        default:
            performSegue(withIdentifier: "ShowMainViewController", sender: nil)
        }
    }
    
}

fileprivate extension EducationViewController {
    
    func viewController(forScreen screen: EducationScreen) -> UIViewController {
        let viewController: UIViewController
        switch screen {
        case .initial:
            viewController = ViewControllersFactory.initialEducationScreen
        case .features:
            viewController = ViewControllersFactory.featuresEducationScreen
        case .notificationsSetupSuggestion:
            viewController = ViewControllersFactory.notificationsSetupSuggestionScreen
        case .pinCodeSetupSuggestion:
            viewController = ViewControllersFactory.pinCodeSetupSuggestionEducationScreen
        case .pinCodeCreation:
            let pinCreationViewController = ViewControllersFactory.pinCreation
            
            pinCreationViewController.onComplete = { [unowned self] in
                self.didAskToContinueEducation(screen: .pinCodeCreation)
            }
            
            viewController = pinCreationViewController
        case .final:
            viewController = ViewControllersFactory.finalEducationScreen
        }
        
        if let educationScreenInput = viewController as? EducationScreenInput {
            educationScreenInput.setupOutput(self)
        }
        
        return viewController
    }
    
}
