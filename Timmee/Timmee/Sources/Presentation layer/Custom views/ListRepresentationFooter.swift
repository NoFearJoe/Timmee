//
//  ListRepresentationFooter.swift
//  Timmee
//
//  Created by i.kharabet on 13.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class ListRepresentationFooter: UITableViewHeaderFooterView {
    
    fileprivate var button: UIButton!
    
    var title: String? {
        didSet {
            button.setTitle(title, for: .normal)
        }
    }
    
    var onTap: (() -> Void)?
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addButton()
        applyAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addButton()
        applyAppearance()
    }
    
    fileprivate func addButton() {
        button = UIButton(frame: .zero)
        self.addSubview(button)
        button.height(32)
        button.centerY().to(self)
        button.centerX().toSuperview()
        button.backgroundColor = AppTheme.current.middlegroundColor
        button.setTitleColor(AppTheme.current.secondaryTintColor, for: .normal)
        button.layer.cornerRadius = 4
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(tap), for: .touchUpInside)
    }
    
    @objc private func tap() {
        onTap?()
    }
    
    func applyAppearance() {
        contentView.backgroundColor = .clear
        backgroundView = UIView()
    }
    
}
