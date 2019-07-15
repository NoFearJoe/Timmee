//
//  LightOrDarkColorResolver.swift
//  DetailsUIKit
//
//  Created by g.novik on 19.04.2018.
//

import UIKit

/// Компонет для выбора между светлым и темным цветов в завимости от переданного
class LightOrDarkColorResolver: IColorResolver {
    
    let lightColor: UIColor
    let darkColor: UIColor
    
    let lightnessCoefficient: CGFloat
    
    init(lightColor: UIColor = .white,
         darkColor: UIColor = .black,
         lightnessCoefficient: CGFloat = 0.75) {
        self.lightColor = lightColor
        self.darkColor = darkColor
        self.lightnessCoefficient = lightnessCoefficient
    }
    
    // MARK: - IColorResolver
    
    func color(basedOn otherColor: UIColor) -> UIColor {
        let colorStyle = self.colorStyle(basedOn: otherColor)
        
        switch colorStyle {
        case .light:
            return lightColor
        case .dark:
            return darkColor
        }
    }
    
    // MARK: - Private
    
    private enum ColorStyle {
        case light
        case dark
    }
    
    private func colorStyle(basedOn backgrounColor: UIColor) -> ColorStyle {
        return isColorBright(backgrounColor) ? .dark : .light
    }
    
    /// Светлый цвет или нет согласно нашей цветовой схеме
    ///
    /// Ссылки:
    /// [W3C color contrast](https://www.w3.org/WAI/ER/WD-AERT/#color-contrast)
    /// [Stack overflow](https://stackoverflow.com/questions/2509443/check-if-uicolor-is-dark-or-bright)
    private func isColorBright(_ color: UIColor) -> Bool {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        let brightness = ((red * 299) + (green * 587) + (blue * 114)) / 1000
        
        return (brightness >= lightnessCoefficient)
    }
}
