//
//  AppTheme.swift
//  Timmee
//
//  Created by Ilya Kharabet on 05.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit
import Workset

public enum AppTheme {
    case white
    case black
    
    public static var current: AppThemeScheme {
        return AppTheme(code: UserProperty.appTheme.int()).scheme
    }
    
    public init(code: Int) {
        switch code {
        case 1: self = .black
        default: self = .white
        }
    }
    
    public var code: Int {
        switch self {
        case .white: return 0
        case .black: return 1
        }
    }
    
    public var title: String {
        switch self {
        case .white: return "white_theme".localized
        case .black: return "black_theme".localized
        }
    }
    
    public var scheme: AppThemeScheme {
        switch self {
        case .white: return AppThemeScheme.new
        case .black: return AppThemeScheme.new
        }
    }
    
    public var next: AppTheme {
        switch self {
        case .white: return .black
        case .black: return .white
        }
    }
}

public struct AppThemeScheme {

    public static let white = AppThemeScheme(backgroundColor: UIColor(rgba: "272727"),
                                      middlegroundColor: UIColor(rgba: "E7E7E7"),
                                      foregroundColor: UIColor(rgba: "FFFFFF"),
                                      tintColor: UIColor(rgba: "2C3539"),
                                      secondaryTintColor: UIColor(rgba: "2C3539").withAlphaComponent(0.6),
                                      thirdlyTintColor: UIColor(rgba: "2C3539").withAlphaComponent(0.3),
                                      backgroundTintColor: .white,
                                      secondaryBackgroundTintColor: UIColor.white.withAlphaComponent(0.6),
                                      specialColor: UIColor(rgba: "0EAEE4"),
                                      panelColor: UIColor(rgba: "EEEEEE"),
                                      tagColors: whiteThemeTagColors)
    
    public static let black = AppThemeScheme(backgroundColor: UIColor(rgba: "141311"),
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
    
    public static let new = AppThemeScheme(backgroundColor: UIColor(rgba: "333333"),
                                           middlegroundColor: UIColor(rgba: "EAECEE"),
                                           foregroundColor: UIColor(rgba: "FFFFFF"),
                                           tintColor: UIColor(rgba: "131D2C"),
                                           secondaryTintColor: UIColor(rgba: "9299a2"),
                                           thirdlyTintColor: UIColor(rgba: "DDDfe0"),
                                           backgroundTintColor: .white,
                                           secondaryBackgroundTintColor: UIColor(rgba: "EAECEE"),
                                           specialColor: UIColor(rgba: "027dc5"),
                                           panelColor: UIColor(rgba: "f9f9f9"),
                                           tagColors: blackThemeTagColors)
    
    public let backgroundColor: UIColor
    public let middlegroundColor: UIColor
    public let foregroundColor: UIColor
    
    public let tintColor: UIColor
    public let secondaryTintColor: UIColor
    public let thirdlyTintColor: UIColor
    
    public let backgroundTintColor: UIColor
    public let secondaryBackgroundTintColor: UIColor
    
    public let specialColor: UIColor
    public let panelColor: UIColor
    
    public let tagColors: [UIColor]
    
    public let redColor: UIColor = UIColor(rgba: "e4002f") // ff2800
    public let blueColor: UIColor = UIColor(rgba: "027dc5") // 0080FF
    public let greenColor: UIColor = UIColor(rgba: "39FF14")
    
    private static let whiteThemeTagColors: [UIColor] = [
        UIColor(rgba: "FF3B30"), UIColor(rgba: "FF9500"), UIColor(rgba: "FFCC00"),
        UIColor(rgba: "4CF964"), UIColor(rgba: "5AC8FA"), UIColor(rgba: "007AFF"),
        UIColor(rgba: "5856D6"), UIColor(rgba: "FF2D55"), UIColor(rgba: "999999")
    ]
    
    private static let blackThemeTagColors: [UIColor] = [
        UIColor(rgba: "FF3B30"), UIColor(rgba: "FF9500"), UIColor(rgba: "FFCC00"),
        UIColor(rgba: "4CF964"), UIColor(rgba: "5AC8FA"), UIColor(rgba: "007AFF"),
        UIColor(rgba: "5856D6"), UIColor(rgba: "FF2D55"), UIColor(rgba: "999999")
    ]

}
