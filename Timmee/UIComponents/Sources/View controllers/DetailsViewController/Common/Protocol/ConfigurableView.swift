//
//  ConfigurableView.swift
//  MBiOS
//
//  Created by g.novik on 28.07.17.
//  Copyright © 2017 АО «Тинькофф Банк», лицензия ЦБ РФ № 2673. All rights reserved.
//

import UIKit

/// Протокол конфигурируемого объекта отображения
public protocol ConfigurableView {
    
    associatedtype DisplayModel
    
    /// Метод для конфигурации объекта отображения моделью
    ///
    /// - Parameter model: ассоциированная модель
    func configure(with model: DisplayModel)
}

/// Протокол объекта отображения со стилем
public protocol StyleAvailableView {
    
    associatedtype Style
    
    /// Метод для применения стиля объекта отображения
    ///
    /// - Parameter model: ассоциированный стиль
    func apply(_ style: Style)
}

extension StyleAvailableView where Self: UIView {
    
    public static func fromNib(with style: Style) -> Self {
        let view = Self.loadedFromNib()
        view.apply(style)
        return view
    }
}
