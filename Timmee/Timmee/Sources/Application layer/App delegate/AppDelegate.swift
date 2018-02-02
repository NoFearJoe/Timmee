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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        
        AppThemeConfigurator.setupInitialThemeIfNeeded()
        
        AppearanceConfigurator.setupAppearance()
        
        if let window = self.window {
            InitialScreenPresenter.presentInitialScreen(inWindow: window)
        }
        
        return true
    }

}
