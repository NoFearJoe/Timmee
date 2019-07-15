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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var titleLabelLeading: NSLayoutConstraint!
    @IBOutlet weak var titleLabelTrailing: NSLayoutConstraint!
    
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
            maximizedStateHeight = attributedText.boundingRect(with: CGSize(width: constrainedWidth, height: 9999),
                                                               options: .usesLineFragmentOrigin,
                                                               context: nil).height
            minimizedStateHeight = model.compressionDisabled ? maximizedStateHeight : minimizedStateHeight
            sizeHelper = DynamicSizeChangeHelper(maximum: maximizedStateHeight, minimum: minimizedStateHeight)
        }
    }
    
    public var maximizedStateHeight: CGFloat = 0
    public var minimizedStateHeight: CGFloat = 0
    
    public func changeCompression(to state: CGFloat) {
        guard let sizeHelper = sizeHelper else { return }
        
        height.constant = sizeHelper.size(for: state)
        let scale = sizeHelper.scale(for: state)
        
        let translationY: CGFloat = titleLabel.bounds.height * (1 - scale)
        titleLabel.transform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: 0, y: translationY)
        
        titleLabel.alpha = transparentDisappearingEnabled ? sizeHelper.alpha(for: state) : 1
    }
    
    // MARK: - ConfigurableView
    
    private var transparentDisappearingEnabled = false
    
    public func configure(with model: Model) {
        self.model = model
            
        titleLabel.attributedText = model.attributedText
        
        titleLabelLeading.constant = model.sideInset
        titleLabelTrailing.constant = model.sideInset
        
        transparentDisappearingEnabled = model.transparentDisappearing
        minimizedStateHeight = model.minimumHeight
        
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
        
        let compressionDisabled: Bool
        
        public init(attributedText: NSAttributedString,
                    transparentDisappearing: Bool = true,
                    minimumHeight: CGFloat = 0,
                    sideInset: CGFloat = .defaultTitleViewSideOffset,
                    compressionDisabled: Bool = false) {
            
            self.attributedText = attributedText
            self.transparentDisappearing = transparentDisappearing
            self.minimumHeight = minimumHeight
            self.sideInset = sideInset
            self.compressionDisabled = compressionDisabled
        }
    }
}

// MARK: - Constants

public extension CGFloat {
    static let defaultTitleViewSideOffset: CGFloat = 32
}
