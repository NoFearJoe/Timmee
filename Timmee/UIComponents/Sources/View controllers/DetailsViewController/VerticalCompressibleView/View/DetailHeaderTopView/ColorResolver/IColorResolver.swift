//
//  IColorResolver.swift
//  DetailsUIKit
//
//  Created by g.novik on 19.04.2018.
//

import UIKit

/// Компонент для определения цвета по другому цвету
protocol IColorResolver {
    
    /// Метод возвращает новый цвет на основе старого
    ///
    /// - Parameter otherColor: Цвет, на основе которого принимается решение
    /// - Returns: Новый цвет
    func color(basedOn otherColor: UIColor) -> UIColor
}
