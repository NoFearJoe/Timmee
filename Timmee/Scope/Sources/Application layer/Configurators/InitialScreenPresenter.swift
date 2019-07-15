//
//  InitialScreenPresenter.swift
//  Timmee
//
//  Created by i.kharabet on 12.01.18.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class InitialScreenPresenter {
    
    static func presentInitialScreen(inWindow window: UIWindow) {
        // Сначала надо показать обучение, если оно не было показано
        // Потом пароль, если установлен
        // Потом основной экран
        
        let initialViewController: UIViewController
        
        if !UserProperty.isEducationShown.bool() {
            initialViewController = ViewControllersFactory.education
        } else if UserProperty.pinCode.value() != nil {
            let pinAuthenticationViewController = ViewControllersFactory.pinAuthentication
            pinAuthenticationViewController.onComplete = { [unowned pinAuthenticationViewController] in
                pinAuthenticationViewController.performSegue(withIdentifier: "ShowMainViewController", sender: nil)
            }
            
            initialViewController = pinAuthenticationViewController
        } else {
            initialViewController = ViewControllersFactory.main
        }
        
        window.rootViewController = initialViewController
        window.makeKeyAndVisible()
    }
    
}
