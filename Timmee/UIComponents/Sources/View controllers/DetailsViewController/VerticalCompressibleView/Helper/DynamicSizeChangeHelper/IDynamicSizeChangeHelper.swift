//
//  IDynamicSizeChangeHelper.swift
//  DetailsUIKitDevelopment
//
//  Created by g.novik on 26.03.2018.
//  Copyright © 2018 g.novik. All rights reserved.
//

import Foundation
import UIKit

/// Протокол вспомогательного объекта для расчета изменения размера
public protocol IDynamicSizeChangeHelper {
    
    /// Максимальный размер объекта
    var maximum: CGFloat { get }
    
    /// Минимальный размер объекта
    var minimum: CGFloat { get }
    
    /// Конструктор вспомогательного объекта для расчета изменения размера
    ///
    /// - Parameters:
    ///   - maximum: Максимальный размер объекта
    ///   - minimum: Минимальный размер объекта
    init(maximum: CGFloat, minimum: CGFloat)
    
    /// Метод возвращает размер для переданного состояния [0; 1]
    ///
    /// - Parameter state: Состояние [0; 1]
    /// - Returns: Размер для переданного состояния [0; 1]
    func size(for state: CGFloat) -> CGFloat
    
    /// Метод возвращает необходимый коэффициент сжатия для переданного состояния [0; 1]
    ///
    /// - Parameter state: Состояние [0; 1]
    /// - Returns: Коэффициент сжатия для переданного состояния [0; 1]
    func scale(for state: CGFloat) -> CGFloat
    
    /// Метод возвращает необходимый коэффециент прозрачности для переданного состояния [0; 1]
    ///
    /// - Parameter state: Состояние [0; 1]
    /// - Returns: Коэффициент прозрачности для переданного состояния [0; 1]
    func alpha(for state: CGFloat) -> CGFloat
}
