//
//  AppDelegate.swift
//  Agile diary
//
//  Created by i.kharabet on 09.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import UserNotifications
import Authorization
import Synchronization
import Firebase
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    lazy var window: UIWindow? = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        return window
    }()
    
    private let initialScreenPresenter = InitialScreenPresenter()
    
    private lazy var synchronizationRunner = PeriodicallySynchronizationRunner(synchronizationService: AgileeSynchronizationService.shared)
    
    private lazy var synchronizationStatusBar: SynchronizationStatusBar = {
        let statusBar = SynchronizationStatusBar(frame: UIApplication.shared.statusBarFrame)
        statusBar.statusBarFrame = { UIApplication.shared.statusBarFrame }
        statusBar.icon = UIImage(named: "sync")
        statusBar.tintColor = .white
        statusBar.backgroundColor = AppTheme.current.colors.mainElementColor
        return statusBar
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)

        Fabric.with([Crashlytics.self])
        
        SynchronizationConfigurator.configure()
        HabitsCollectionsLoader.initialize()
        
        UNUserNotificationCenter.current().delegate = self
        NotificationsConfigurator.updateNotificationCategoriesIfPossible(application: application)
        
        
        ProVersionPurchase.shared.loadStore()
        
        synchronizationRunner.delegate = self
        
        initialScreenPresenter.presentPreInitialScreen(in: self.window)
        performPreparingActions {
            self.initialScreenPresenter.presentInitialScreen(in: self.window) {
                self.synchronizationRunner.run(interval: 10, delay: 10)
            }
        }
        
        BackgroundImagesLoader.shared.load()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let canOpenWithFacebook = FBSDKApplicationDelegate.sharedInstance()?.application(app, open: url, options: options) ?? false
        return canOpenWithFacebook
    }

}

extension AppDelegate: PeriodicallySynchronizationRunnerDelegate {
    
    func willStartSynchronization() {
        synchronizationStatusBar.show()
    }
    
    func didFinishSynchronization() {
        synchronizationStatusBar.hide()
    }
    
}

private extension AppDelegate {
    func performPreparingActions(completion: @escaping () -> Void) {
        self.performMigrations {
            print("Preparing: migrations are finished")
            self.performOtherPreparingActions {
                print("Preparing: other preparing actions are finished")
                self.performInitialSynchronization {
                    print("Preparing: Synchronization is finished")
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        }
    }
    
    private func performMigrations(completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        ServicesAssembly.shared.waterControlService.performMigration {
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main, execute: completion)
    }
    
    private func performOtherPreparingActions(completion: @escaping () -> Void) {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        ServicesAssembly.shared.habitsService.setRepeatEndingDateForAllHabitsIfNeeded {
            self.rescheduleAllNotifications()
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main, execute: completion)
    }
    
    private func performInitialSynchronization(completion: @escaping () -> Void) {
        if SynchronizationAvailabilityChecker.shared.synchronizationEnabled {
            AgileeSynchronizationService.shared.sync { success in
                completion()
            }
        } else {
            completion()
        }
    }
}

private extension AppDelegate {
    func rescheduleAllNotifications() {
        let allHabits = EntityServicesAssembly.shared.habitsService.fetchAllHabitsInBackground().map { Habit(habit: $0) }
        allHabits.forEach { habit in
            HabitsSchedulerService.shared.scheduleHabit(habit)
        }
    }
}
