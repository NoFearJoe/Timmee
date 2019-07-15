//
//  VerticalCompressibleView.swift
//  MobileBank
//
//  Created by g.novik on 16.01.2018.
//  Copyright © 2018 АО «Тинькофф Банк», лицензия ЦБ РФ № 2673. All rights reserved.
//

import Foundation
import UIKit

/// Протокол вертикально-сжимаемого объекта отображения
public protocol VerticalCompressibleView {
    
    /// Высота объекта отображения в развернутом состоянии
    var maximizedStateHeight: CGFloat { get }
    
    /// Высота объекта отображения в сжатом состоянии
    var minimizedStateHeight: CGFloat { get }
    
    /// Метод изменяет коэффициент сжатия объекта
    ///
    /// - Parameter state: Коэффициент сжатия
    func changeCompression(to state: CGFloat)
    
    /// Метод обновляет высоты динамических блоков
    ///
    /// - Note: Опциональный метод, необходимый для пересчета высот у объектов с динамическим контентом
    func updateHeights()
}

extension VerticalCompressibleView {
    
    /// Различие высоты объекта отображения между развернутым и сжатым состоянием
    public var minMaxStateHeightDifference: CGFloat {
        return maximizedStateHeight - minimizedStateHeight
    }
    
    /// Стандартная пустая реализация опционального метода
    public func updateHeights() {}
}
