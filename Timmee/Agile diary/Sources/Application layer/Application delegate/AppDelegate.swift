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
    
    var window: UIWindow?
    
    lazy var synchronizationRunner = PeriodicallySynchronizationRunner(synchronizationService: AgileeSynchronizationService.shared)
    
    lazy var synchronizationStatusBar: SynchronizationStatusBar = {
        let statusBar = SynchronizationStatusBar(frame: UIApplication.shared.statusBarFrame)
        statusBar.statusBarFrame = { UIApplication.shared.statusBarFrame }
        statusBar.icon = UIImage(named: "sync")
        statusBar.tintColor = .white
        statusBar.backgroundColor = AppTheme.current.colors.mainElementColor
        return statusBar
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        
        AuthorizationService.initializeAuthorization()
        AgileeSynchronizationService.initializeSynchronization()
        AgileeSynchronizationService.shared.checkSynchronizationConditions = {
            ProVersionPurchase.shared.isPurchased()
        }
        FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        UNUserNotificationCenter.current().delegate = self
        NotificationsConfigurator.updateNotificationCategoriesIfPossible(application: application)
        
        if let window = window {
            #if MOCKS
            RuMocksConfigurator.prepareMocks {
                UserProperty.isInitialSprintCreated.setBool(true)
                InitialScreenPresenter().showToday()
            }
            #else
            InitialScreenPresenter().presentInitialScreen(inWindow: window)
            #endif
        }
        
        ProVersionPurchase.shared.loadStore()
        
        synchronizationRunner.delegate = self
        synchronizationRunner.run(interval: 30)
        
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

