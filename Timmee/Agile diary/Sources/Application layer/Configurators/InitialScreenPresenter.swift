//
//  InitialScreenPresenter.swift
//  Agile diary
//
//  Created by i.kharabet on 13.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

final class InitialScreenPresenter: SprintInteractorTrait {
    
    let sprintsService = ServicesAssembly.shared.sprintsService
    
    func presentPreInitialScreen(in window: UIWindow?) {
        window?.rootViewController = ViewControllersFactory.preInitialScreen
        window?.makeKeyAndVisible()
    }
    
    func presentInitialScreen(in window: UIWindow?, completion: @escaping () -> Void) {
        guard let window = window else { return }
        #if MOCKS
//        PastSprintMocksConfigurator.prepareMocks { [weak self] in
//            UserProperty.isEducationShown.setBool(true)
            self.presentRealInitialScreen(in: window)
            completion()
//            self?.presentMockInitialScreen(in: window)
//        }
        #else
        presentRealInitialScreen(in: window)
        completion()
        #endif
    }
    
    private func presentMockInitialScreen(in window: UIWindow) {
        showToday(in: window)
    }
    
    private func presentRealInitialScreen(in window: UIWindow) {
        // Сначала надо показать обучение, если оно не было показано
        // Потом пароль, если установлен
        // Потом создание первого спринта, если он не был создан
        // Потом основной экран
        
        let initialViewController: UIViewController
        
        if !UserProperty.isEducationShown.bool() {
            initialViewController = ViewControllersFactory.education
        } else if UserProperty.pinCode.value() != nil {
            let pinAuthenticationViewController = ViewControllersFactory.pinAuthentication
            pinAuthenticationViewController.onComplete = { [unowned self] in
                if self.getCurrentSprint() == nil, self.getNextSprint() == nil {
                    self.showSprintCreation(in: window)
                } else {
                    self.showToday(in: window)
                }
            }

            initialViewController = pinAuthenticationViewController
        } else if getCurrentSprint() == nil, getNextSprint() == nil {
            initialViewController = ViewControllersFactory.sprintCreation
        } else {
            initialViewController = ViewControllersFactory.today
        }
        
        if let rootViewController = window.rootViewController {
            initialViewController.loadViewIfNeeded()
            UIView.transition(from: rootViewController.view, to: initialViewController.view, duration: 0.25, options: .transitionCrossDissolve) { _ in
                window.rootViewController = initialViewController
                window.makeKeyAndVisible()
            }
        } else {
            window.rootViewController = initialViewController
            window.makeKeyAndVisible()
        }
    }
    
    private func showSprintCreation(in window: UIWindow) {
        guard let rootView = window.rootViewController?.view else { return }
        let sprintCreationViewController = ViewControllersFactory.sprintCreation
        sprintCreationViewController.loadViewIfNeeded()
        UIView.transition(from: rootView, to: sprintCreationViewController.view, duration: 0.25, options: .transitionCrossDissolve) { _ in
            window.rootViewController = sprintCreationViewController
            window.makeKeyAndVisible()
        }
    }
    
    private func showToday(in window: UIWindow) {
        guard let rootView = window.rootViewController?.view else { return }
        let todayViewController = ViewControllersFactory.today
        todayViewController.loadViewIfNeeded()
        UIView.transition(from: rootView, to: todayViewController.view, duration: 0.25, options: .transitionCrossDissolve) { _ in
            window.rootViewController = todayViewController
            window.makeKeyAndVisible()
        }
    }
    
}
