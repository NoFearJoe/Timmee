//
//  AppDelegate+Shortcuts.swift
//  Scope
//
//  Created by i.kharabet on 16/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import Foundation

extension AppDelegate {
    
    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        guard let shortcutType = ShortcutType(shortcutString: shortcutItem.type) else {
            completionHandler(false)
            return
        }
        
        GlobalRoutingManager.shared.currentTarget = shortcutType.globalRoutingTarget
        
        completionHandler(true)
    }
    
}

enum ShortcutType: String {
    case createSingleTask
    case createRegularTask
    
    init?(shortcutString: String) {
        switch shortcutString.split(separator: ".").last {
        case "createSingleTask"?: self = .createSingleTask
        case "createRegularTask"?: self = .createRegularTask
        default: return nil
        }
    }
    
    var globalRoutingTarget: GlobalRoutingTarget {
        switch self {
        case .createSingleTask: return .taskEditor(.single)
        case .createRegularTask: return .taskEditor(.regular)
        }
    }
}
