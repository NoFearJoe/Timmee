//
//  AppDelegate.swift
//  Agile diary
//
//  Created by i.kharabet on 09.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import Intents
import TasksKit
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    lazy var window: UIWindow? = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        AppWindowRouter.shared.window = window
        return window
    }()
    
    private let initialScreenPresenter = InitialScreenPresenter()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        NotificationsConfigurator.updateNotificationCategoriesIfPossible(application: application)
        
        NotificationsConfigurator.removeAppIconBadge()
        
        SwiftyStoreKit.completeTransactions()
        
        AppThemeApplier.applyTheme()
        
        NSArraySecureUnarchiveFromData.registerTransformer()
        _ = Database.localStorage
        
        _ = window
        
        if UserProperty.isEducationShown.bool() {
            UserProperty.isFreeLaunchPerformed.setBool(true)
        }
        
        initialScreenPresenter.presentPreInitialScreen()
        performPreparingActions {
            self.initialScreenPresenter.presentInitialScreen {}
        }
        
        BackgroundImagesLoader.shared.load()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onThemeChanged),
            name: AppTheme.themeChanged,
            object: nil
        )
        
        return true
    }

}

private extension AppDelegate {
    func performPreparingActions(completion: @escaping () -> Void) {
        self.performOtherPreparingActions {
            print("Preparing: other preparing actions are finished")
            DispatchQueue.main.async {
                completion()
            }
        }
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
    
    @objc func onThemeChanged() {
        AppThemeApplier.applyTheme()
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
