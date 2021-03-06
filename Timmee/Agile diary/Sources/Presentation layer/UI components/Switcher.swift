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
    
    var items: [SwitcherItem] = [] {
        didSet {
            createItemViews(with: items)
        }
    }
    
    var selectedItemIndex: Int = 0 {
        didSet {
            selectItemView(at: selectedItemIndex, oldIndex: oldValue)
        }
    }
    
    private func createItemViews(with items: [SwitcherItem]) {
        itemViews.forEach { $0.removeFromSuperview() }
        
        itemViews = []
        for (index, item) in items.enumerated() {
            let view = SwitcherItemView(frame: .zero)
            view.setItem(item)
            view.roundedCorners = index == 0 ? .left : index >= items.count - 1 ? .right : .none
            view.isSelected = false
            view.setupAppearance()
            view.isUserInteractionEnabled = false
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
        UIView.performWithoutAnimation {
            let iconWidth = max(bounds.height, 56)
            let iconsWidth = iconWidth * CGFloat(items.filter { $0 is UIImage }.count)
            let labelWidth = (bounds.width - iconsWidth) / CGFloat(items.filter { $0 is String }.count)
            var offsetX: CGFloat = 0
            for (index, view) in itemViews.enumerated() {
                let width = items[index] is UIImage ? iconWidth : labelWidth
                view.frame = CGRect(x: offsetX, y: 0, width: width, height: bounds.height)
                offsetX += width
            }
        }
    }
    
    private func selectItemView(at index: Int, oldIndex: Int = 0) {
        itemViews.item(at: oldIndex)?.isSelected = false
        itemViews.item(at: selectedItemIndex)?.isSelected = true
        sendActions(for: .touchUpInside)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let selectedViewIndex = itemViews.firstIndex(where: { itemView in
            touches.contains(where: { touch in
                itemView.frame.contains(touch.location(in: self))
            })
        }) else { return }
        selectedItemIndex = selectedViewIndex
    }
    
    func setupAppearance() {
        itemViews.forEach { $0.setupAppearance() }
    }
    
}

// MARK: - Switcher item view

protocol SwitcherItem {}

extension String: SwitcherItem {}
extension UIImage: SwitcherItem {}

class SwitcherItemView: UIView {
    
    func setItem(_ item: SwitcherItem) {
        if let string = item as? String {
            titleLabel.text = string
        } else if let icon = item as? UIImage {
            iconView.image = icon
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = AppTheme.current.fonts.medium(14)
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        return label
    }()
    
    private let iconView: UIImageView = {
        let iconView = UIImageView(frame: .zero)
        iconView.contentMode = .scaleAspectFit
        iconView.isUserInteractionEnabled = false
        return iconView
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
        addSubview(iconView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(titleLabel)
        addSubview(iconView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateMaskLayer()
        titleLabel.frame = bounds
        iconView.frame = bounds.insetBy(dx: 4, dy: 4)
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
