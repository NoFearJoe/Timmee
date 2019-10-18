//
//  ActionSheetItemView.swift
//  UIComponents
//
//  Created by i.kharabet on 18/10/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import Workset

final class ActionSheetItemView: UIView {
    
    override var tintColor: UIColor? {
        didSet {
            iconView.tintColor = tintColor
            titleLabel.tintColor = tintColor
        }
    }
    
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    
    private let item: ActionSheetItem
    
    init(item: ActionSheetItem) {
        self.item = item
        
        super.init(frame: .zero)
        
        setupViews()
        setupLayout()
        
        iconView.image = item.icon
        titleLabel.text = item.title
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(tapRecognizer)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    @objc private func onTap() {
        item.action()
    }
    
}

private extension ActionSheetItemView {
    
    func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(iconView)
        iconView.contentMode = .scaleAspectFit
        iconView.clipsToBounds = true
        iconView.isUserInteractionEnabled = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        titleLabel.isUserInteractionEnabled = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupLayout() {
        iconView.width(20)
        iconView.height(20)
        [iconView.leading(16), iconView.centerY()].toSuperview()
        
        [titleLabel.trailing(16), titleLabel.centerY()].toSuperview()
        titleLabel.leadingToTrailing(12).to(iconView, addTo: self)
    }
    
}
