//
//  InitialScreenPresenter.swift
//  Agile diary
//
//  Created by i.kharabet on 13.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

final class InitialScreenPresenter: SprintInteractorTrait {
    
    let sprintsService = ServicesAssembly.shared.sprintsService
    
    func presentInitialScreen(inWindow window: UIWindow) {
        // Сначала надо показать обучение, если оно не было показано
        // Потом пароль, если установлен
        // Потом создание первого спринта, если он не был создан
        // Потом основной экран
        
        let initialViewController: UIViewController
        
        if !UserProperty.isEducationShown.bool() {
            initialViewController = ViewControllersFactory.education
        } else if UserProperty.pinCode.value() != nil {
            let pinAuthenticationViewController = ViewControllersFactory.pinAuthentication
            pinAuthenticationViewController.onComplete = {
                if !UserProperty.isInitialSprintCreated.bool() {
                    self.showSprintCreation()
                } else {
                    self.showToday()
                }
            }

            initialViewController = pinAuthenticationViewController
        } else if !UserProperty.isInitialSprintCreated.bool(), getCurrentSprint() == nil, getNextSprint() == nil {
            initialViewController = ViewControllersFactory.sprintCreation
        } else {
            initialViewController = ViewControllersFactory.today
        }
        
        window.rootViewController = initialViewController
        window.makeKeyAndVisible()
    }
    
    func showSprintCreation() {
        guard let rootView = AppDelegate.shared.window?.rootViewController?.view else { return }
        let sprintCreationViewController = ViewControllersFactory.sprintCreation
        sprintCreationViewController.loadViewIfNeeded()
        UIView.transition(with: rootView, duration: 0.25, options: .transitionCrossDissolve, animations: {
            AppDelegate.shared.window?.rootViewController = sprintCreationViewController
        }, completion: nil)
    }
    
    func showToday() {
        guard let rootView = AppDelegate.shared.window?.rootViewController?.view else { return }
        let todayViewController = ViewControllersFactory.today
        todayViewController.loadViewIfNeeded()
        UIView.transition(with: rootView, duration: 0.25, options: .transitionCrossDissolve, animations: {
            AppDelegate.shared.window?.rootViewController = todayViewController
        }, completion: nil)
    }
    
}
