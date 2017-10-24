//
//  AppTheme.swift
//  Timmee
//
//  Created by Ilya Kharabet on 05.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

enum AppTheme {
    case white
    case black
    
    static let current = AppTheme(code: UserProperty.appTheme.int())
    
    init(code: Int) {
        switch code {
        case 1: self = .black
        default: self = .white
        }
    }
    
    var code: Int {
        switch self {
        case .white: return 0
        case .black: return 1
        }
    }
    
    var scheme: AppThemeScheme {
        switch self {
        case .white: return AppThemeScheme.white
        case .black: return AppThemeScheme.black
        }
    }
}

struct AppThemeScheme {

    static let white = AppThemeScheme(backgroundColor: UIColor(rgba: "FFFFFF"),
                                      cellBackgroundColor: UIColor(rgba: "E1E5E5"),
                                      tintColor: UIColor(rgba: "2C3539"),
                                      secondaryTintColor: UIColor(rgba: "2C3539").withAlphaComponent(0.75),
                                      cellTintColor: UIColor(rgba: "2C3539"),
                                      specialColor: UIColor(rgba: "0EAEE4"),
                                      panelColor: UIColor(rgba: "EEEEEE"),
                                      tagColors: whiteThemeTagColors)
    
    static let black = AppThemeScheme(backgroundColor: UIColor(rgba: "202020"),
                                      cellBackgroundColor: .white,
                                      tintColor: .white,
                                      secondaryTintColor: UIColor.white.withAlphaComponent(0.75),
                                      cellTintColor: UIColor(rgba: "202020"),
                                      specialColor: UIColor(rgba: "FFD700"),
                                      panelColor: UIColor(rgba: "EEEEEE"),
                                      tagColors: blackThemeTagColors)
    
    let backgroundColor: UIColor
    let cellBackgroundColor: UIColor
    let tintColor: UIColor
    let secondaryTintColor: UIColor
    let cellTintColor: UIColor
    let specialColor: UIColor
    let panelColor: UIColor
    
    let tagColors: [UIColor]
    
    let redColor: UIColor = UIColor(rgba: "EB4949")
    let blueColor: UIColor = UIColor(rgba: "0EAEE4")
    let greenColor: UIColor = UIColor(rgba: "42EC62")
    
    fileprivate static let whiteThemeTagColors: [UIColor] = [
        UIColor(rgba: "EB4949"), UIColor(rgba: "0EAEE4"), UIColor(rgba: "42EC62"),
        UIColor(rgba: "999999"), UIColor(rgba: "FFD700"), UIColor(rgba: "EB4949"),
        UIColor(rgba: "EB4949"), UIColor(rgba: "EB4949"), UIColor(rgba: "EB4949"),
        UIColor(rgba: "EB4949"), UIColor(rgba: "EB4949"), UIColor(rgba: "EB4949")
    ]
    
    fileprivate static let blackThemeTagColors: [UIColor] = [
        UIColor(rgba: "EB4949"), UIColor(rgba: "0EAEE4"), UIColor(rgba: "42EC62"),
        UIColor(rgba: "999999"), UIColor(rgba: "FFD700"), UIColor(rgba: "EB4949"),
        UIColor(rgba: "EB4949"), UIColor(rgba: "EB4949"), UIColor(rgba: "EB4949"),
        UIColor(rgba: "EB4949"), UIColor(rgba: "EB4949"), UIColor(rgba: "EB4949")
    ]

}
