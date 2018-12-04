//
//  AppDelegate.swift
//  Agile diary
//
//  Created by i.kharabet on 09.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        NotificationsConfigurator.updateNotificationCategoriesIfPossible(application: application)
//        ServicesAssembly.shared.waterControlService.removeWaterControl(completion: nil)
        
        if let window = window {
            #if MOCKS
            EnMocksConfigurator.prepareMocks {
                UserProperty.isInitialSprintCreated.setBool(true)
                InitialScreenPresenter.showToday()
            }
            #else
            InitialScreenPresenter.presentInitialScreen(inWindow: window)
            #endif
        }
        
        return true
    }

}

