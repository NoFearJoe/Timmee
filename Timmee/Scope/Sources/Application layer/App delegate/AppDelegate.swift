//
//  AppDelegate.swift
//  Timmee
//
//  Created by Ilya Kharabet on 20.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        NotificationsConfigurator.setupNotifications(application: application)
        NotificationsConfigurator.updateNotificationCategoriesIfPossible()
        
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        
        Trackers.registerAppLaunchTracker()
                
        AppThemeConfigurator.setupInitialThemeIfNeeded()
        
        AppearanceConfigurator.setupAppearance()
        
        if let window = self.window {
            InitialScreenPresenter.presentInitialScreen(inWindow: window)
        }
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationsConfigurator.removeAppIconBadge()
    }

}
