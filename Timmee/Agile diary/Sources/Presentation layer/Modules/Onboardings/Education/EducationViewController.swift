//
//  EducationViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 13.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import Synchronization

protocol EducationScreenInput: class {
    func setupOutput(_ output: EducationScreenOutput)
}

protocol EducationScreenOutput: class {
    func didAskToContinueEducation(screen: EducationScreen)
    func didAskToSkipEducation(screen: EducationScreen)
}

final class EducationViewController: UINavigationController, SprintInteractorTrait, AlertInput {
    
    let sprintsService = ServicesAssembly.shared.sprintsService
    
    private let educationState = EducationState()
    
    private var synchronizationDidFinishObservation: Any?
    private var isSynchronized = false
    private var shouldShowAppropriateScreenAfterSynchronization = false
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return AppThemeType.current == .dark ? .lightContent : .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeToSynchronizationCompletion()
        
        if let initialScreen = educationState.screensToShow.first {
            setViewControllers([viewController(forScreen: initialScreen)], animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserProperty.isEducationShown.setBool(true)
    }
    
    private var shouldShowSprintCreationAfterEducation: Bool {
        return getCurrentSprint() == nil && getNextSprint() == nil
    }
    
    private func showAppropriateScreenAfterEducation() {
        if SynchronizationAvailabilityChecker.shared.synchronizationEnabled && !isSynchronized {
            shouldShowAppropriateScreenAfterSynchronization = true
//            showAlert(title: "attention".localized,
//                      message: "wait_until_sync_is_complete".localized,
//                      actions: [.ok("Ok")],
//                      completion: nil)
            pushViewController(viewController(forScreen: .sync), animated: true)
            return
        }
        if shouldShowSprintCreationAfterEducation {
            hideAlert(animated: false)
            showSprintCreation()
        } else {
            hideAlert(animated: false)
            showToday()
        }
    }
    
    private func showSprintCreation() {
        let sprintCreationViewController = ViewControllersFactory.sprintCreation
        sprintCreationViewController.loadViewIfNeeded()
        UIView.transition(with: self.view, duration: 0.25, options: .transitionCrossDissolve, animations: {
            AppDelegate.shared.window?.rootViewController = sprintCreationViewController
        }, completion: nil)
    }
    
    private func showToday() {
        guard let rootView = AppDelegate.shared.window?.rootViewController?.view else { return }
        let todayViewController = ViewControllersFactory.today
        todayViewController.loadViewIfNeeded()
        UIView.transition(with: rootView, duration: 0.25, options: .transitionCrossDissolve, animations: {
            AppDelegate.shared.window?.rootViewController = todayViewController
        }, completion: nil)
    }
    
}

extension EducationViewController: EducationScreenOutput {
    
    func didAskToContinueEducation(screen: EducationScreen) {
        guard let currentScreenIndex = educationState.screensToShow.index(of: screen),
              let nextScreen = educationState.screensToShow.item(at: currentScreenIndex + 1)
        else {
            showAppropriateScreenAfterEducation()
            return
        }
        
        let isLastScreen = currentScreenIndex + 1 >= educationState.screensToShow.count - 1
        
        if nextScreen == .proVersion, ProVersionPurchase.shared.isPurchased() {
            // Если PRO версия куплена, то соответствующий экран не показывается
            didAskToContinueEducation(screen: .proVersion)
        } else if !isLastScreen || (isLastScreen && shouldShowSprintCreationAfterEducation) {
            // Основной флоу обучения
            pushViewController(viewController(forScreen: nextScreen), animated: true)
        } else {
            // Если находимся на последнем экране и после него не надо показать экран создания спринта
            showAppropriateScreenAfterEducation()
        }
    }
    
    func didAskToSkipEducation(screen: EducationScreen) {
        switch screen {
        case .notificationsSetupSuggestion:
            didAskToContinueEducation(screen: .notificationsSetupSuggestion)
        case .pinCodeSetupSuggestion:
            didAskToContinueEducation(screen: .pinCodeCreation)
        case .proVersion:
            didAskToContinueEducation(screen: .proVersion)
        default:
            showAppropriateScreenAfterEducation()
        }
    }
    
}

fileprivate extension EducationViewController {
    
    func viewController(forScreen screen: EducationScreen) -> UIViewController {
        let viewController: UIViewController
        switch screen {
        case .initial:
            viewController = ViewControllersFactory.initialEducationScreen
        case .immutableSprints:
            viewController = ViewControllersFactory.immutableSprintsEducationScreen
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
        case .proVersion:
            viewController = ViewControllersFactory.proVersionEducationScreen
        case .sync:
            viewController = ViewControllersFactory.synchronizationEducationScreen
        case .final:
            viewController = ViewControllersFactory.finalEducationScreen
        }
        
        if let educationScreenInput = viewController as? EducationScreenInput {
            educationScreenInput.setupOutput(self)
        }
        
        return viewController
    }
    
}

private extension EducationViewController {
    
    func subscribeToSynchronizationCompletion() {
        let notificationName = NSNotification.Name(rawValue: PeriodicallySynchronizationRunner.didFinishSynchronizationNotificationName)
        synchronizationDidFinishObservation = NotificationCenter.default
            .addObserver(
                forName: notificationName,
                object: nil,
                queue: .main)
            { [weak self] _ in
                guard let self = self else { return }
                self.isSynchronized = true
                guard self.shouldShowAppropriateScreenAfterSynchronization else { return }
                self.showAppropriateScreenAfterEducation()
            }
    }
    
}
