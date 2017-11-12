//
//  ListIconCell.swift
//  Timmee
//
//  Created by Ilya Kharabet on 11.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class ListIconCell: UICollectionViewCell {
    
    @IBOutlet fileprivate weak var iconView: UIImageView!
    
    var icon: ListIcon? {
        didSet {
            iconView.image = icon?.image
        }
    }
    
    override var isSelected: Bool {
        didSet {
            iconView.tintColor = isSelected ? AppTheme.current.blueColor : AppTheme.current.panelColor
        }
    }
    
}
