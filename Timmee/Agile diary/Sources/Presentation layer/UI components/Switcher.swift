//
//  Switcher.swift
//  Agile diary
//
//  Created by i.kharabet on 13.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

class Switcher: UIControl {
    
    private var itemViews: [SwitcherItemView] = []
    
    var items: [String] = [] {
        didSet {
            createItemViews(with: items)
        }
    }
    
    var selectedItemIndex: Int = 0 {
        didSet {
            itemViews.item(at: oldValue)?.isSelected = false
            itemViews.item(at: selectedItemIndex)?.isSelected = true
            sendActions(for: .touchUpInside)
        }
    }
    
    private func createItemViews(with items: [String]) {
        itemViews.forEach { $0.removeFromSuperview() }
        
        itemViews = []
        for (index, item) in items.enumerated() {
            let view = SwitcherItemView(frame: .zero)
            view.titleLabel.text = item
            view.roundedCorners = index == 0 ? .left : index >= items.count - 1 ? .right : .none
            view.isSelected = false
            view.setupAppearance()
            addSubview(view)
            itemViews.append(view)
        }
        
        layoutItemViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutItemViews()
    }
    
    private func layoutItemViews() {
        let width = bounds.width / CGFloat(itemViews.count)
        for (index, view) in itemViews.enumerated() {
            view.frame = CGRect(x: CGFloat(index) * width, y: 0, width: width, height: bounds.height)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedItemIndex = itemViews.index { itemView in
            return touches.contains(where: { touch in
                itemView.frame.contains(touch.location(in: self))
            })
        } ?? 0
    }
    
    func setupAppearance() {
        itemViews.forEach { $0.setupAppearance() }
    }
    
}

class SwitcherItemView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = AppTheme.current.fonts.medium(14)
        label.textAlignment = .center
        return label
    }()
    
    enum RoundedCorners {
        case none, left, right
    }
    
    private let maskLayer = CAShapeLayer()
    
    var roundedCorners: RoundedCorners = .none {
        didSet {
            updateMaskLayer()
        }
    }
    
    var isSelected: Bool = false {
        didSet {
            backgroundColor = isSelected ? AppTheme.current.colors.selectedElementColor : AppTheme.current.colors.decorationElementColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateMaskLayer()
        titleLabel.frame = bounds
    }
    
    func updateMaskLayer() {
        maskLayer.frame = bounds
        let corners: UIRectCorner
        switch roundedCorners {
        case .none: corners = .init(rawValue: 0)
        case .left: corners = [.bottomLeft, .topLeft]
        case .right: corners = [.bottomRight, .topRight]
        }
        maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
        layer.mask = maskLayer
    }
    
    func setupAppearance() {
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        backgroundColor = isSelected ? AppTheme.current.colors.selectedElementColor : AppTheme.current.colors.decorationElementColor
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
    }
    
}
