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
    func educationScreenDidEndPresentation()
}

final class EducationViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

extension EducationViewController: EducationScreenOutput {
    
    func educationScreenDidEndPresentation() {
        
    }
    
}

fileprivate extension EducationViewController {
    
    func viewController(forScreen screen: EducationScreen) -> UIViewController {
        let viewController: UIViewController
        switch screen {
        case .initial:
            return UIViewController()
        case .features:
            return UIViewController()
        case .pinCodeSetupSuggestion:
            return UIViewController()
        case .pinCodeCreation:
            return ViewControllersFactory.pinCreation
        }
        
        if let educationScreenInput = viewController as? EducationScreenInput {
            educationScreenInput.setupOutput(self)
        }
        
        return viewController
    }
    
}
