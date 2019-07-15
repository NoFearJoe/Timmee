//
//  TagCollectionViewCell.swift
//  Scope
//
//  Created by i.kharabet on 15/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class TagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var colorView: TagCollectionColorView!
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var color: UIColor {
        get { return colorView.color }
        set { colorView.color = newValue }
    }
    
}

final class TagCollectionColorView: UIView {
    
    var color: UIColor {
        get { return backgroundColor ?? .clear }
        set { backgroundColor = newValue }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = AppTheme.current.cornerRadius
    }
    
}
