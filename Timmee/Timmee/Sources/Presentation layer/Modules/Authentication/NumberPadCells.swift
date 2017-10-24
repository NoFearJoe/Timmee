//
//  NumberPadCell.swift
//  Test
//
//  Created by i.kharabet on 13.10.17.
//  Copyright © 2017 i.kharabet. All rights reserved.
//

import class UIKit.UICollectionViewCell
import class UIKit.UIView
import class UIKit.UILabel
import class UIKit.UIImageView
import class UIKit.UIColor

class BasePadCell: UICollectionViewCell {

    var defaultBackgroundColor: UIColor = UIColor.clear
    var highlightedBackgroundColor: UIColor = AppTheme.current.scheme.panelColor
    
    var item: NumberPadItem!
    
    override var isHighlighted: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        clipsToBounds = true
        backgroundColor = defaultBackgroundColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.width * 0.5
    }
    
    func configure(with item: NumberPadItem) {
        self.item = item
    }
    
    fileprivate func updateBackgroundColor() {
        backgroundColor = isHighlighted ? highlightedBackgroundColor : defaultBackgroundColor
    }

}

final class NumberPadCell: BasePadCell {
    
    @IBOutlet fileprivate var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = AppTheme.current.scheme.tintColor
        }
    }
    
    override func configure(with item: NumberPadItem) {
        super.configure(with: item)
        
        if case .number(let value) = item.style {
            titleLabel.text = String(value)
        } else if case .symbol(let string) = item.style {
            titleLabel.text = string
        }
    }
    
}

final class IconPadCell: BasePadCell {
    
    @IBOutlet fileprivate var iconView: UIImageView! {
        didSet {
            iconView.tintColor = AppTheme.current.scheme.tintColor
        }
    }
    
    override func configure(with item: NumberPadItem) {
        super.configure(with: item)
        
        guard case .icon(let image) = item.style else { return }
        
        iconView.image = image
    }
    
}
