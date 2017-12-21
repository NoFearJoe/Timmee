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
    
    static var current: AppThemeScheme {
        return AppTheme(code: UserProperty.appTheme.int()).scheme
    }
    
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
    
    var title: String {
        switch self {
        case .white: return "white_theme".localized
        case .black: return "black_theme".localized
        }
    }
    
    var scheme: AppThemeScheme {
        switch self {
        case .white: return AppThemeScheme.white
        case .black: return AppThemeScheme.black
        }
    }
    
    var next: AppTheme {
        switch self {
        case .white: return .black
        case .black: return .white
        }
    }
}

struct AppThemeScheme {

    static let white = AppThemeScheme(backgroundColor: UIColor(rgba: "303737"),
                                      middlegroundColor: UIColor(rgba: "E0E0E0"),
                                      foregroundColor: UIColor(rgba: "FFFFFF"),
                                      tintColor: UIColor(rgba: "2C3539"),
                                      secondaryTintColor: UIColor(rgba: "2C3539").withAlphaComponent(0.6),
                                      thirdlyTintColor: UIColor(rgba: "2C3539").withAlphaComponent(0.3),
                                      backgroundTintColor: .white,
                                      secondaryBackgroundTintColor: UIColor.white.withAlphaComponent(0.6),
                                      specialColor: UIColor(rgba: "0EAEE4"),
                                      panelColor: UIColor(rgba: "EEEEEE"),
                                      tagColors: whiteThemeTagColors)
    
    static let black = AppThemeScheme(backgroundColor: UIColor(rgba: "141311"),
                                      middlegroundColor: UIColor(rgba: "686766"),
                                      foregroundColor: UIColor(rgba: "B7B7B6"),
                                      tintColor: UIColor(rgba: "141311"),
                                      secondaryTintColor: UIColor(rgba: "141311").withAlphaComponent(0.6),
                                      thirdlyTintColor: UIColor(rgba: "141311").withAlphaComponent(0.3),
                                      backgroundTintColor: .white,
                                      secondaryBackgroundTintColor: UIColor.white.withAlphaComponent(0.6),
                                      specialColor: UIColor(rgba: "FFD700"),
                                      panelColor: UIColor(rgba: "EEEEEE"),
                                      tagColors: blackThemeTagColors)
    
    let backgroundColor: UIColor
    let middlegroundColor: UIColor
    let foregroundColor: UIColor
    
    let tintColor: UIColor
    let secondaryTintColor: UIColor
    let thirdlyTintColor: UIColor
    
    let backgroundTintColor: UIColor
    let secondaryBackgroundTintColor: UIColor
    
    let specialColor: UIColor
    let panelColor: UIColor
    
    let tagColors: [UIColor]
    
    let redColor: UIColor = UIColor(rgba: "EB4949")
    let blueColor: UIColor = UIColor(rgba: "0EAEE4")
    let greenColor: UIColor = UIColor(rgba: "42EC62")
    
    fileprivate static let whiteThemeTagColors: [UIColor] = [
        UIColor(rgba: "FF3B30"), UIColor(rgba: "FF9500"), UIColor(rgba: "FFCC00"),
        UIColor(rgba: "4CF964"), UIColor(rgba: "5AC8FA"), UIColor(rgba: "007AFF"),
        UIColor(rgba: "5856D6"), UIColor(rgba: "FF2D55"), UIColor(rgba: "999999")
    ]
    
    fileprivate static let blackThemeTagColors: [UIColor] = [
        UIColor(rgba: "FF3B30"), UIColor(rgba: "FF9500"), UIColor(rgba: "FFCC00"),
        UIColor(rgba: "4CF964"), UIColor(rgba: "5AC8FA"), UIColor(rgba: "007AFF"),
        UIColor(rgba: "5856D6"), UIColor(rgba: "FF2D55"), UIColor(rgba: "999999")
    ]

}
