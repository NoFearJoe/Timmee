//
//  IDetailsContent.swift
//  MobileBankUI
//
//  Created by a.y.zverev on 19.01.2018.
//  Copyright © 2018 АО «Тинькофф Банк», лицензия ЦБ РФ № 2673. All rights reserved.
//

import UIKit

// MARK: - Обобщенный протокол

/// Обобщенный протокол для интерфейсов необходимых модулю деталей
public typealias DetailModuleProvider
    = DetailsModuleLocalDataAvailabilty
    & DetailsModuleElementsProvider
    & DetailsModulePlaceholdersProvider
    & DetailsModuleViewConfiguration
    & DetailsModuleDataManager

// MARK: - Управление загрузкой данных в модуль

/// Интерфейс, отражающий состояние локальной доступности данных для отображения модуля
public protocol DetailsModuleLocalDataAvailabilty {
    
    /// Данные для хедера доступны без дополнительной загрузки
    var cachedHeaderDataAvailable: Bool { get }
    
    /// Данные для контента доступны без дополнительной загрузки
    var cachedContentDataAvailable: Bool { get }
}

public extension DetailsModuleLocalDataAvailabilty {
    
    /// Данные для контента и хедера доступны без дополнительной загрузки
    var cachedFullDataAvailable: Bool {
        return cachedHeaderDataAvailable && cachedContentDataAvailable
    }
}

// MARK: - Управление основными элементами модуля

/// Интерфейс для управления основными элементами оторбражения модуля
public protocol DetailsModuleElementsProvider {
    
    // Шапка
    var header: UIViewController & VerticalCompressibleViewContainer { get }
    
    // Контент
    var stackViewContainer: UIScrollView & ITCSStackViewContainer { get }
}

// MARK: - Управление плейсхолдерами основных элементов модуля

/// Протокол объекта отображения, содержащего в себе анимацию
public protocol AnimatableView {
    
    /// Метод стартует заложенную в объект анимацию
    func startAnimating()
    
    /// Метод останавливает заложенную в объект анимацию
    func stopAnimating()
    
    /// Метод очищает объект от запущенных анимаций
    func clearAnimations()
}

/// Интерфейс для управления плейсхолдерами основных элементов модуля
public protocol DetailsModulePlaceholdersProvider {
    
    /// Плейсхолдер для всего модуля деталей
    var fullPlaceholder: UIView & AnimatableView { get }
    
    /// Плейсхолдер только для контента деталей
    var contentPlaceholder: UIView & AnimatableView { get }
}

// MARK: - Конфигурация отображения

public struct DetailsContentViewConfiguration {
    
    public let bottomBackgroundColor: UIColor
    public var errorPlaceholderTextColor: UIColor
    
    public init(bottomBackgroundColor: UIColor,
                errorPlaceholderTextColor: UIColor) {
        
        self.bottomBackgroundColor = bottomBackgroundColor
        self.errorPlaceholderTextColor = errorPlaceholderTextColor
    }
}

/// В протоколе содержатся возможности для настройки отображения модуля деталей

/// Интерфейс, отражающий конфигурацию отображения модуля
public protocol DetailsModuleViewConfiguration {
    
    // Конфигурация отображения модуля деталей
    var viewConfiguration: DetailsContentViewConfiguration { get }
}

// MARK: - Управление загрузкой данных

public protocol DetailsModuleDataManager {
    
    // Дозагрузка данных
    func loadContent(completion: @escaping (Error?) -> Void)
    
    // Метод, который вызывается клиентским кодом для обновления данных
    func reloadContent()
}
