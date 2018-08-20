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
    }
    
    struct Fonts {
        func regular(_ size: CGFloat) -> UIFont {
            return UIFont.avenirNextRegular(size)
        }
        
        func medium(_ size: CGFloat) -> UIFont {
            return UIFont.avenirNextMedium(size)
        }
        
        func bold(_ size: CGFloat) -> UIFont {
            return UIFont.avenirNextBold(size)
        }
    }
    
    let colors: Colors
    let fonts: Fonts
    
    static let light = AppTheme(colors: Colors(inactiveElementColor: UIColor(rgba: ""),
                                               activeElementColor: UIColor(rgba: ""),
                                               mainElementColor: UIColor(rgba: ""),
                                               wrongElementColor: UIColor(rgba: ""),
                                               selectedElementColor: UIColor(rgba: ""),
                                               decorationElementColor: UIColor(rgba: "")),
                                fonts: Fonts())
    
    static let dark = AppTheme(colors: Colors(inactiveElementColor: UIColor(rgba: ""),
                                              activeElementColor: UIColor(rgba: ""),
                                              mainElementColor: UIColor(rgba: ""),
                                              wrongElementColor: UIColor(rgba: ""),
                                              selectedElementColor: UIColor(rgba: ""),
                                              decorationElementColor: UIColor(rgba: "")),
                               fonts: Fonts())
    
    static var current: AppTheme {
        return .light
    }
    
}
