//
//  CompressibleEmptyView.swift
//  MobileBank
//
//  Created by g.novik on 24.01.2018.
//  Copyright © 2018 АО «Тинькофф Банк», лицензия ЦБ РФ № 2673. All rights reserved.
//

import UIKit

public final class CompressibleEmptyView: UIView, VerticalCompressibleView, ConfigurableView {
    
    /// Outlet
    private var height: NSLayoutConstraint?
    
    /// Dependency
    private var sizeHelper: DynamicSizeChangeHelper?
    
    // MARK: - VerticalCompressibleView
    
    public var maximizedStateHeight: CGFloat = 0
    public var minimizedStateHeight: CGFloat = 0
    
    public func changeCompression(to state: CGFloat) {
        guard let sizeHelper = sizeHelper, let model = model else {
            return
        }
        
        height?.constant = model.reversed
            ? sizeHelper.size(for: (1 - state))
            : sizeHelper.size(for: state)
    }
    
    // MARK: - ConfigurableView
    
    private var model: Model?
    
    public func configure(with model: Model) {
        // Save model
        self.model = model
        
        // Configure height
        height = self.heightAnchor.constraint(equalToConstant: 0)
        height?.isActive = true
        
        // Update view with model
        backgroundColor = model.backgroundColor
        
        maximizedStateHeight = model.reversed ? model.minimizedStateHeight : model.maximizedStateHeight
        minimizedStateHeight = model.reversed ? model.maximizedStateHeight : model.minimizedStateHeight
        
        sizeHelper = DynamicSizeChangeHelper(maximum: model.maximizedStateHeight,
                                             minimum: model.minimizedStateHeight)
    }
}

// MARK: - Display model

public extension CompressibleEmptyView {
    
    public struct Model {
        
        let backgroundColor: UIColor
        
        let maximizedStateHeight: CGFloat
        let minimizedStateHeight: CGFloat
        
        let reversed: Bool
        
        public static func uncompressible(backgroundColor: UIColor, height: CGFloat) -> Model {
            return Model(backgroundColor: backgroundColor,
                         maximizedStateHeight: height,
                         minimizedStateHeight: height)
        }
        
        public init(backgroundColor: UIColor,
                    maximizedStateHeight: CGFloat,
                    minimizedStateHeight: CGFloat = 0,
                    reversed: Bool = false) {
            
            self.backgroundColor = backgroundColor
            self.maximizedStateHeight = maximizedStateHeight
            self.minimizedStateHeight = minimizedStateHeight
            self.reversed = reversed
        }
    }
}
