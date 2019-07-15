//
//  VerticalCompressibleViewContainer.swift
//  DetailsUIKit
//
//  Created by g.novik on 01.04.2018.
//

import Foundation

/// Протокол контейнера вертикально-сжимаемых объектов отображения
public protocol VerticalCompressibleViewContainer: VerticalCompressibleView {
    
    /// Метод добавляет новый вертикально-сжимаемый объект отображения в контейнер
    ///
    /// - Parameter compressibleView: Вертикально-сжимаемый объект отображения
    func add(compressibleView: UIView & VerticalCompressibleView)
}
