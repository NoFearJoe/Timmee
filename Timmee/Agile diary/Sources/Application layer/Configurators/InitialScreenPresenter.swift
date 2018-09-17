//
//  InitialScreenPresenter.swift
//  Agile diary
//
//  Created by i.kharabet on 13.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

final class InitialScreenPresenter {
    
    static func presentInitialScreen(inWindow window: UIWindow) {
        // Сначала надо показать обучение, если оно не было показано
        // Потом пароль, если установлен
        // Потом создание первого спринта, если он не был создан
        // Потом основной экран
        
        let initialViewController: UIViewController
        
        if !UserProperty.isEducationShown.bool() {
            initialViewController = ViewControllersFactory.education
        } else if UserProperty.pinCode.value() != nil {
            let pinAuthenticationViewController = ViewControllersFactory.pinAuthentication
            pinAuthenticationViewController.onComplete = { [unowned pinAuthenticationViewController] in
                pinAuthenticationViewController.performSegue(withIdentifier: "ShowTodayViewController", sender: nil)
            }

            initialViewController = pinAuthenticationViewController
        } else if !UserProperty.isInitialSprintCreated.bool() {
            initialViewController = ViewControllersFactory.sprintCreation
        } else {
            initialViewController = ViewControllersFactory.today
        }
        
        window.rootViewController = initialViewController
        window.makeKeyAndVisible()
    }
    
}
