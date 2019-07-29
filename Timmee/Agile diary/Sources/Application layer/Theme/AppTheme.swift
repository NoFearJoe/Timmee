//
//  AppTheme.swift
//  Agile diary
//
//  Created by i.kharabet on 20.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

enum AppThemeType: Int {
    case light = 0
    case dark
    
    var title: String {
        switch self {
        case .light: return "light_theme".localized
        case .dark: return "dark_theme".localized
        }
    }
    
    var next: AppThemeType {
        switch self {
        case .light: return .dark
        case .dark: return .light
        }
    }
    
    static var current: AppThemeType {
        return AppThemeType(rawValue: UserProperty.appTheme.int()) ?? .light
    }
}

struct AppTheme {
    
    struct Colors {
        let inactiveElementColor: UIColor
        let activeElementColor: UIColor
        let mainElementColor: UIColor
        let wrongElementColor: UIColor
        let selectedElementColor: UIColor
        let incompleteElementColor: UIColor
        let decorationElementColor: UIColor
        
        let foregroundColor: UIColor
        let middlegroundColor: UIColor
        let backgroundColor: UIColor
    }
    
    struct Fonts {
        func regular(_ size: CGFloat) -> UIFont {
            return .systemFont(ofSize: size) //UIFont.avenirNextRegular(size)
        }
        
        func medium(_ size: CGFloat) -> UIFont {
            return .systemFont(ofSize: size, weight: .medium) //UIFont.avenirNextMedium(size)
        }
        
        func bold(_ size: CGFloat) -> UIFont {
            return .boldSystemFont(ofSize: size) //UIFont.avenirNextBold(size)
        }
    }
    
    struct Style {
        
        struct Alpha {
            let transparent: CGFloat = 0
            let disabled: CGFloat = 0.5
            let inactive: CGFloat = 0.75
            let enabled: CGFloat = 1
        }
        
        let alpha = Alpha()
        
    }
    
    let colors: Colors
    let fonts: Fonts
    let style = Style()
    
    static let light = AppTheme(colors: Colors(inactiveElementColor: UIColor(rgba: "AAAAAA"),
                                               activeElementColor: UIColor(rgba: "444444"),
                                               mainElementColor: UIColor(rgba: "29C3FE"),
                                               wrongElementColor: UIColor(rgba: "FF3100"),
                                               selectedElementColor: UIColor(rgba: "12FFA3"),
                                               incompleteElementColor: UIColor(rgba: "FEE200"),
                                               decorationElementColor: UIColor(rgba: "E9E9E9"),
                                               foregroundColor: UIColor(rgba: "FFFFFF"),
                                               middlegroundColor: UIColor(rgba: "F5F5F5"),
                                               backgroundColor: UIColor(rgba: "888888")),
                                fonts: Fonts())
    
    static let dark = AppTheme(colors: Colors(inactiveElementColor: UIColor(rgba: "BBBBBB"),
                                              activeElementColor: UIColor(rgba: "FFFFFF"),
                                              mainElementColor: UIColor(rgba: "29C3FE"),
                                              wrongElementColor: UIColor(rgba: "FF3100"),
                                              selectedElementColor: UIColor(rgba: "0AED95"),
                                              incompleteElementColor: UIColor(rgba: "FEE200"),
                                              decorationElementColor: UIColor(rgba: "666666"),
                                              foregroundColor: UIColor(rgba: "5B5B5B"),
                                              middlegroundColor: UIColor(rgba: "444444"),
                                              backgroundColor: UIColor(rgba: "0A0A0A")),
                               fonts: Fonts())
    
    static var current: AppTheme {
        switch AppThemeType.current {
        case .light: return .light
        case .dark: return .dark
        }
    }
    
}

extension AppTheme {
    
    var textColorForTodayLabelsOnBackground: UIColor {
        if ProVersionPurchase.shared.isPurchased() && BackgroundImage.current != .noImage {
            return AppThemeType.current == .light ? colors.foregroundColor : colors.activeElementColor
        } else {
            return colors.activeElementColor
        }
    }
    
    var clearImage: UIImage? {
        switch AppThemeType.current {
        case .light:
            return UIImage(named: "clear_light")
        case .dark:
            return UIImage(named: "clear_dark")
        }
    }
    
}

extension AppTheme {
    
    var keyboardStyleForTheme: UIKeyboardAppearance {
        return AppThemeType.current == .light ? .light : .dark
    }
    
}
