//
//  InitialScreenPresenter.swift
//  Agile diary
//
//  Created by i.kharabet on 13.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

final class InitialScreenPresenter: SprintInteractorTrait {
    
    let sprintsService = ServicesAssembly.shared.sprintsService
    
    func presentPreInitialScreen() {
        AppWindowRouter.shared.show(screen: ViewControllersFactory.preInitialScreen)
    }
    
    func presentInitialScreen(completion: @escaping () -> Void) {
        #if MOCKS
//        PastSprintMocksConfigurator.prepareMocks { [weak self] in
//            UserProperty.isEducationShown.setBool(true)
            self.presentRealInitialScreen(in: window)
            completion()
//            self?.presentMockInitialScreen(in: window)
//        }
        #else
        presentRealInitialScreen()
        completion()
        #endif
    }
    
    private func presentMockInitialScreen() {
        showToday()
    }
    
    private func presentRealInitialScreen() {
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
                    self.showSprintCreation()
                } else {
                    self.showToday()
                }
            }

            initialViewController = pinAuthenticationViewController
        } else if getCurrentSprint() == nil, getNextSprint() == nil {
            initialViewController = SprintCreationViewController(sprint: nil, canBeClosed: false)
        } else {
            initialViewController = ViewControllersFactory.today
        }
        
        AppWindowRouter.shared.show(screen: initialViewController)
    }
    
    private func showSprintCreation() {
        AppWindowRouter.shared.show(screen: SprintCreationViewController(sprint: nil, canBeClosed: false))
    }
    
    private func showToday() {
        AppWindowRouter.shared.show(screen: ViewControllersFactory.today)
    }
    
}

final class AppWindowRouter {
    
    static let shared = AppWindowRouter()
    
    unowned var window: UIWindow?
    
    func show(screen: UIViewController) {
        guard let window = window else { return }
        
        screen.loadViewIfNeeded()
        screen.view.frame = window.bounds
        screen.view.setNeedsLayout()
        screen.view.layoutIfNeeded()
        
        if window.rootViewController != nil {
            window.subviews.forEach { $0.removeFromSuperview() }
            
            window.rootViewController = screen
            
            UIView.transition(
                with: window,
                duration: 0.35,
                options: .transitionCrossDissolve,
                animations: nil,
                completion: nil
            )
        } else {
            window.rootViewController = screen
        }
    }
    
}
