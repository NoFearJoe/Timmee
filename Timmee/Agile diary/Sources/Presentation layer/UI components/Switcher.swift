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
    
}

class SwitcherItemView: GradientView {
    
    let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .black
        label.font = UIFont.avenirNextRegular(16)
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
            startColor = isSelected ? UIColor(rgba: "7FFDFE") : UIColor(rgba: "f9f9f9")
            endColor = isSelected ? UIColor(rgba: "8CDFFC") : UIColor(rgba: "f5f5f5")
            titleLabel.textColor = isSelected ? .white : .black
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        setupAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(titleLabel)
        setupAppearance()
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
    
    private func setupAppearance() {
        startPoint = CGPoint(x: 1, y: 0)
        endPoint = CGPoint(x: 0, y: 1)
    }
    
}
