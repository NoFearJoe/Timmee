//
//  DetailHeaderTopView.swift
//  MobileBank
//
//  Created by g.novik on 16.01.2018.
//  Copyright © 2018 АО «Тинькофф Банк», лицензия ЦБ РФ № 2673. All rights reserved.
//

import Foundation
import UIKit
import ImageProcessor

/// Верхний блок шапки деталей
public final class DetailHeaderTopView: UIView, VerticalCompressibleView, ConfigurableView {
    
    // Outlet
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet public weak var closeButton: UIButton!
    
    @IBOutlet weak var navigationBarPlaceholder: UIView!
    @IBOutlet weak var navigationBarPlaceholderBottom: UIView!
    
    @IBOutlet weak var imageBlock: UIView!
    @IBOutlet weak var imageBlockTop: UIView!
    @IBOutlet weak var imageBackgroundView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    // Constraint
    @IBOutlet weak var navigationBarPlaceholderHeight: NSLayoutConstraint!
    @IBOutlet weak var imageBlockHeight: NSLayoutConstraint!
    
    // Dependency
    var colorResolver: IColorResolver = LightOrDarkColorResolver()
    
    // Size helper
    private let navigationBarPlaceholderSizeHelper = DynamicSizeChangeHelper(maximum: .navigationBarPlaceholderMaxHeight,
                                                                             minimum: .navigationBarPlaceholderMinHeight)
    private let imageBlockSizeHelper = DynamicSizeChangeHelper(maximum: .imageBlockMaxHeight,
                                                               minimum: .imageBlockMinHeight)
    
    // Configuration
    var style: Style = Style() // default
    var model: Model?
    
    // MARK: - Actions
    
    public var closeButtonTappedAction: (() -> Void)?
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        closeButtonTappedAction?()
    }
    
    // MARK: - Lifecycle
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        configureUI()
        changeCompression(to: .maximizedState)
    }
    
    private func configureUI() {
        navigationBarPlaceholder.layer.cornerRadius = .cornerRadius12
        
        imageBackgroundView.clipsToBounds = true
        imageView.clipsToBounds = true
    }
    
    // MARK: - VerticalCompressibleView
    
    public var minimizedStateHeight: CGFloat {
        return .navigationBarPlaceholderMinHeight + .imageBlockMinHeight - emptyTitleHeightModificator
    }
    
    public var maximizedStateHeight: CGFloat {
        return .navigationBarPlaceholderMaxHeight + .imageBlockMaxHeight - emptyTitleHeightModificator
    }
    
    private var emptyTitleHeightModificator: CGFloat {
        var modificator: CGFloat = 0
        if let model = model, model.title.isEmpty, !UIDevice.current.isIpad {
            modificator = .navigationBarPlaceholderTitleHeight
        }
        
        return modificator
    }
    
    public func changeCompression(to state: CGFloat) {
        navigationBarPlaceholderHeight.constant = navigationBarPlaceholderSizeHelper.size(for: state) - emptyTitleHeightModificator
        
        let imageHeight = imageBlockSizeHelper.size(for: state)
        imageBlockHeight.constant = imageHeight
        
        imageBackgroundView.layer.cornerRadius = imageHeight / 2
        imageView.layer.cornerRadius = (imageHeight - .imageBorder) / 2
    }
    
    // MARK: - ConfigurableView
    
    public func configure(with model: Model) {
        self.model = model
        
        dateLabel.text = model.title
        configureImage(model.imageResolver)
        changeCompression(to: .maximizedState)
    }
    
    // MARK: - Private
    
    private func configureImage(_ imageResolver: IImageResolver) {
        let size = (contentMode == .scaleToFill) ? bounds.size : nil
        
        imageResolver.resolve { [weak self] (result, error) in
            guard let result = result, error == nil else { return }
            
            var image = result.image
            if let size = size {
                image = image?.tcs.resized(size)
            }
            
            DispatchQueue.main.tcs.safeAsync {
                if result.tintColor != nil {
                    image = image?.withRenderingMode(.alwaysTemplate)
                }
                
                self?.imageView.image = image
                self?.imageView.backgroundColor = result.backgroundColor
                self?.imageView.tintColor = result.tintColor
                
                if let backgroundColor = result.backgroundColor {
                    self?.updateTextColorsBased(on: backgroundColor)
                }
            }
        }
    }

    private func updateTextColorsBased(on backgroundColor: UIColor) {
        imageBlockTop.backgroundColor = backgroundColor
        navigationBarPlaceholder.backgroundColor = backgroundColor
        navigationBarPlaceholderBottom.backgroundColor = backgroundColor
        
        let textColorBasedOnBackground = colorResolver.color(basedOn: backgroundColor)
        
        dateLabel.textColor = textColorBasedOnBackground
        closeButton.setTitleColor(textColorBasedOnBackground, for: .normal)
    }
}

// MARK: - Constants

private extension CGFloat {
    
    static let navigationBarPlaceholderMaxHeight: CGFloat = 54
    static let navigationBarPlaceholderMinHeight: CGFloat = 44
    
    static let navigationBarPlaceholderTitleHeight: CGFloat = 20
    
    static let imageBlockMaxHeight: CGFloat = 80 + .imageBorder
    static let imageBlockMinHeight: CGFloat = 40 + .imageBorder
    static let imageBorder: CGFloat = 8
    
    static let cornerRadius12: CGFloat = 12
}

// MARK: - Model

extension DetailHeaderTopView {
    
    /// Модель отображения для верхнего блока шапки деталей
    public struct Model {
        
        public let title: String
        public let imageResolver: IImageResolver
        
        public init(title: String, imageResolver: IImageResolver) {
            self.title = title
            self.imageResolver = imageResolver
        }
        
        public init(title: String, image: UIImage?, backgroundColor: UIColor? = nil) {
            let staticImageResolver = StaticImageResolver(image: image,
                                                          backgroundColor: backgroundColor)
            self.init(title: title, imageResolver: staticImageResolver)
        }
        
        public init(title: String, imageName: String?, backgroundColor: UIColor? = nil) {
            let staticImageNameResolver = LocalImageResolver(imageName: imageName,
                                                             backgroundColor: backgroundColor)
            self.init(title: title, imageResolver: staticImageNameResolver)
        }
        
        public init(title: String, imageUrl: String,
                    backgroundColor: UIColor? = nil,
                    contentColor: UIColor? = nil,
                    defaultImage: UIImage? = nil) {
            
            let urlImageResolver = URLImageResolver(url: imageUrl,
                                                    backgroundColor: backgroundColor,
                                                    contentColor: contentColor,
                                                    defaultImage: defaultImage)
            self.init(title: title, imageResolver: urlImageResolver)
        }
    }
}

// MARK: - Style

extension DetailHeaderTopView: StyleAvailableView {
    
    /// Конфигурация отображения
    public struct Style {
        
        // MARK: - Фоновые цвета
        
        /// Конфигурация фоновых цветов
        public struct BackgroundColors {
            
            let topColor: UIColor
            let bottomColor: UIColor
            
            public init(topColor: UIColor = UIColor(red: 0.90, green: 0.93, blue: 0.96, alpha: 1.0),
                        bottomColor: UIColor = UIColor(red: 0.96, green: 0.97, blue: 0.97, alpha: 1.0)) {
                self.topColor = topColor
                self.bottomColor = bottomColor
            }
        }
        
        // MARK: - Цвета текста и кнопки
        
        /// Конфигурация цветов текста
        public struct TitleColors {
            
            let darkColor: UIColor
            let lightColor: UIColor
            
            public init(darkColor: UIColor = .black, lightColor: UIColor = .white) {
                self.darkColor = darkColor
                self.lightColor = lightColor
            }
        }
        
        // MARK: - Общий стиль
        
        let backgroundColors: BackgroundColors
        let titleColors: TitleColors
        
        public init(backgroundColors: BackgroundColors = BackgroundColors(),
                    titleColors: TitleColors = TitleColors()) {
            self.backgroundColors = backgroundColors
            self.titleColors = titleColors
        }
    }
    
    public func apply(_ style: DetailHeaderTopView.Style) {
        /// Установка логики смены темного/светлого текста
        let titleColors = style.titleColors
        
        colorResolver = LightOrDarkColorResolver(lightColor: titleColors.lightColor,
                                                 darkColor: titleColors.darkColor)
        
        /// Установка фоновых цветов
        let backgroundColors = style.backgroundColors
        let topColor = backgroundColors.topColor
        let bottomColor = backgroundColors.bottomColor
        
        /// Верхняя часть
        navigationBarPlaceholder.backgroundColor = topColor
        navigationBarPlaceholderBottom.backgroundColor = topColor
        imageBlockTop.backgroundColor = topColor
        imageView.backgroundColor = topColor
        
        /// Нижняя часть
        imageBlock.backgroundColor = bottomColor
        imageBackgroundView.backgroundColor = bottomColor
    }
}
