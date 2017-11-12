//
//  InAppPurchases.swift
//  Timmee
//
//  Created by Ilya Kharabet on 06.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIImage
import class UIKit.UIColor

enum InAppPurchaseItem {
    case darkTheme
    case tags
    case dateTemplates
    
    static var allNotPurchased: [InAppPurchaseItem] =
        [.tags, .dateTemplates]
        .filter { !$0.isPurchased }
    
}

extension InAppPurchaseItem {
    
    var id: String {
        switch self {
        case .darkTheme: return "dark_theme"
        case .tags: return "tags"
        case .dateTemplates: return "date_templates"
        }
    }
    
    var productID: String {
        switch self {
        case .darkTheme: return "com.mesterra.timmee.darkTheme"
        case .tags: return "com.mesterra.timmee.tags"
        case .dateTemplates: return "com.mesterra.timmee.dateTemplates"
        }
    }
    
    var icon: UIImage {
        switch self {
        case .darkTheme: return #imageLiteral(resourceName: "faceIDBig")
        case .tags: return #imageLiteral(resourceName: "touchIDBig")
        case .dateTemplates: return #imageLiteral(resourceName: "faceIDBig")
        }
    }
    
    var title: String {
        switch self {
        case .darkTheme: return "dark_theme_inapp_title".localized
        case .tags: return "tags_inapp_title".localized
        case .dateTemplates: return "date_templates_inapp_title".localized
        }
    }
    
    var description: String {
        switch self {
        case .darkTheme: return "dark_theme_inapp_description".localized
        case .tags: return "tags_inapp_description".localized
        case .dateTemplates: return "date_templates_inapp_description".localized
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .darkTheme: return UIColor(rgba: "202020")
        case .tags: return .white
        case .dateTemplates: return .white
        }
    }
    
    var tintColor: UIColor {
        switch self {
        case .darkTheme: return .white
        case .tags: return UIColor(rgba: "202020")
        case .dateTemplates: return UIColor(rgba: "202020")
        }
    }
    
    var isPurchased: Bool {
        return UserProperty.inApp(id).bool()
    }
    
    var purchase: InAppPurchase {
        return allInAppPurchases[id]!
    }
    
}

let allInAppPurchases = [
//    InAppPurchaseItem.darkTheme.id: InAppPurchase(id: InAppPurchaseItem.darkTheme.id),
    InAppPurchaseItem.tags.id: InAppPurchase(id: InAppPurchaseItem.tags.id),
    InAppPurchaseItem.dateTemplates.id: InAppPurchase(id: InAppPurchaseItem.dateTemplates.id)
]
