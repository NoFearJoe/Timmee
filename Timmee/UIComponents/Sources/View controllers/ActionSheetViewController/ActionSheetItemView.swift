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
            titleLabel.tintColor = tintColor
        }
    }
    
    private let selectionView = UIView()
    private let titleLabel = UILabel()
    
    private let item: ActionSheetItem
    
    init(item: ActionSheetItem) {
        self.item = item
        
        super.init(frame: .zero)
        
        setupViews()
        setupLayout()
        
        titleLabel.text = item.title
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(tapRecognizer)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    @objc private func onTap() {
        item.action()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        selectionView.backgroundColor = UIColor.black.withAlphaComponent(0.15)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        selectionView.backgroundColor = .clear
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        selectionView.backgroundColor = .clear
    }
    
}

private extension ActionSheetItemView {
    
    func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(selectionView)
        selectionView.isUserInteractionEnabled = false
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        titleLabel.isUserInteractionEnabled = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
    }
    
    func setupLayout() {
        selectionView.allEdges().toSuperview()
        
        [titleLabel.trailing(16), titleLabel.centerY(), titleLabel.leading(16)].toSuperview()
    }
    
}
