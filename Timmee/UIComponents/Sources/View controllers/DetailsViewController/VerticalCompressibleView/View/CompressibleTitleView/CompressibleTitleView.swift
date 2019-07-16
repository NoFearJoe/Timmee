//
//  CompressibleTitleView.swift
//  MobileBank
//
//  Created by g.novik on 19.01.2018.
//  Copyright © 2018 АО «Тинькофф Банк», лицензия ЦБ РФ № 2673. All rights reserved.
//

import UIKit

public final class CompressibleTitleView: UIView, VerticalCompressibleView, ConfigurableView {
    
    /// Outlet
    @IBOutlet public var titleLabel: UILabel!
    @IBOutlet var height: NSLayoutConstraint!
    @IBOutlet var titleLabelLeading: NSLayoutConstraint!
    @IBOutlet var titleLabelTrailing: NSLayoutConstraint!
    
    /// Model
    private var model = Model(attributedText: NSAttributedString(string: ""))
    
    /// Dependency
    private var sizeHelper: DynamicSizeChangeHelper?
    
    // MARK: - VerticalCompressibleView
    
    public func updateHeights() {
        if let attributedText = titleLabel.attributedText {
            // Подготовка
            titleLabel.sizeToFit()
            setNeedsLayout()
            layoutIfNeeded()
            
            // Установка максимальной высоты блока
            let constrainedWidth = (frame.width - model.sideInset * 2)
            let maxAttributedText = NSAttributedString(string: attributedText.string, attributes: [.font: model.defaultFont])
            maximizedStateHeight = ceil(maxAttributedText.boundingRect(with: CGSize(width: constrainedWidth, height: 9999),
                                                                       options: .usesLineFragmentOrigin,
                                                                       context: nil).height)
            let minAttributedText = NSAttributedString(string: attributedText.string, attributes: [.font: model.minimumFont])
            minimizedStateHeight = ceil(minAttributedText.boundingRect(with: CGSize(width: constrainedWidth, height: 9999),
                                                                       options: .usesLineFragmentOrigin,
                                                                       context: nil).height) + 2
            sizeHelper = DynamicSizeChangeHelper(maximum: maximizedStateHeight, minimum: minimizedStateHeight)
        }
    }
    
    public var maximizedStateHeight: CGFloat = 0
    public var minimizedStateHeight: CGFloat = 0
    
    public func changeCompression(to state: CGFloat) {
        guard let sizeHelper = sizeHelper else { return }
        
        height.constant = sizeHelper.size(for: state)
        let scale = sizeHelper.scale(for: state)
        let fontSize = min(model.defaultFont.pointSize, max(model.minimumFont.pointSize, model.defaultFont.pointSize * scale))
        let newFont = model.defaultFont.withSize(fontSize)
        titleLabel.font = newFont
        
        titleLabel.alpha = transparentDisappearingEnabled ? sizeHelper.alpha(for: state) : 1
    }
    
    // MARK: - ConfigurableView
    
    private var transparentDisappearingEnabled = false
    
    public func configure(with model: Model) {
        self.model = model
            
        titleLabel.attributedText = model.attributedText
        titleLabel.font = model.defaultFont
        
        titleLabelLeading.constant = model.sideInset
        titleLabelTrailing.constant = model.sideInset
        
        transparentDisappearingEnabled = model.transparentDisappearing
        
        updateHeights()
    }
}

// MARK: - Display model

extension CompressibleTitleView {
    
    public struct Model {
        
        let attributedText: NSAttributedString
        let transparentDisappearing: Bool
        let minimumHeight: CGFloat
        let sideInset: CGFloat
        let defaultFont: UIFont
        let minimumFont: UIFont
        
        let compressionDisabled: Bool
        
        public init(attributedText: NSAttributedString,
                    transparentDisappearing: Bool = true,
                    minimumHeight: CGFloat = 0,
                    sideInset: CGFloat = .defaultTitleViewSideOffset,
                    defaultFont: UIFont = UIFont.systemFont(ofSize: 34, weight: .bold),
                    minimumFont: UIFont = UIFont.systemFont(ofSize: 20, weight: .bold),
                    compressionDisabled: Bool = false) {
            
            self.attributedText = attributedText
            self.transparentDisappearing = transparentDisappearing
            self.minimumHeight = minimumHeight
            self.sideInset = sideInset
            self.defaultFont = defaultFont
            self.minimumFont = minimumFont
            self.compressionDisabled = compressionDisabled
        }
    }
}

// MARK: - Constants

public extension CGFloat {
    static let defaultTitleViewSideOffset: CGFloat = 32
}
