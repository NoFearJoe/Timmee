//
//  AppTheme.swift
//  Agile diary
//
//  Created by i.kharabet on 20.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

enum AppThemeType {
    case light
    case dark
}

struct AppTheme {
    
    struct Colors {
        let inactiveElementColor: UIColor
        let activeElementColor: UIColor
        let mainElementColor: UIColor
        let wrongElementColor: UIColor
        let selectedElementColor: UIColor
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
                                               decorationElementColor: UIColor(rgba: "E9E9E9"),
                                               foregroundColor: UIColor(rgba: "FFFFFF"),
                                               middlegroundColor: UIColor(rgba: "F5F5F5"),
                                               backgroundColor: UIColor(rgba: "888888")),
                                fonts: Fonts())
    
    static let dark = AppTheme(colors: Colors(inactiveElementColor: UIColor(rgba: ""),
                                              activeElementColor: UIColor(rgba: ""),
                                              mainElementColor: UIColor(rgba: ""),
                                              wrongElementColor: UIColor(rgba: ""),
                                              selectedElementColor: UIColor(rgba: ""),
                                              decorationElementColor: UIColor(rgba: ""),
                                              foregroundColor: UIColor(rgba: ""),
                                              middlegroundColor: UIColor(rgba: ""),
                                              backgroundColor: UIColor(rgba: "")),
                               fonts: Fonts())
    
    static var current: AppTheme {
        return .light
    }
    
}
