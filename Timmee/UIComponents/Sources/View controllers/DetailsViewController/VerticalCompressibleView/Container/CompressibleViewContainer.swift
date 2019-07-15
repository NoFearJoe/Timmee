//
//  CompressibleViewContainer.swift
//  MobileBank
//
//  Created by g.novik on 16.01.2018.
//  Copyright © 2018 АО «Тинькофф Банк», лицензия ЦБ РФ № 2673. All rights reserved.
//

import UIKit

/// Контейнер вертикально-сжимаемых объектов отображения
public final class CompressibleViewContainer: UIView, VerticalCompressibleViewContainer {
    
    // Outlet
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet public var backgroundView: UIView!
    
    // Internal
    private var arrangedViews = [UIView & VerticalCompressibleView]()
    
    // MARK: - VerticalCompressibleViewContainer
    
    public func updateHeights() {
        arrangedViews.forEach { $0.updateHeights() }
    }
    
    public func add(compressibleView: UIView & VerticalCompressibleView) {
        stackView.addArrangedSubview(compressibleView)
        arrangedViews.append(compressibleView)
    }
    
    public var minimizedStateHeight: CGFloat {
        let height = arrangedViews.reduce(0.0, { (result, arrangedView) -> CGFloat in
            let minimizedStateHeight = arrangedView.isHidden ? 0 : arrangedView.minimizedStateHeight
            return (result + minimizedStateHeight)
        })
        
        return height
    }
    
    public var maximizedStateHeight: CGFloat {
        let height = arrangedViews.reduce(0.0, { (result, arrangedView) -> CGFloat in
            let maximizedStateHeight = arrangedView.isHidden ? 0 : arrangedView.maximizedStateHeight
            return (result + maximizedStateHeight)
        })
        
        return height
    }
    
    public func changeCompression(to state: CGFloat) {
        arrangedViews.forEach { $0.changeCompression(to: state) }
    }
    
    // MARK: - Lifecycle
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.topLeft, .topRight], radius: 12)
    }
}
