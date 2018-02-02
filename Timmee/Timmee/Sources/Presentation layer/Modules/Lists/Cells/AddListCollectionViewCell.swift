//
//  AddListCollectionViewCell.swift
//  Timmee
//
//  Created by i.kharabet on 31.01.18.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class AddListCollectionViewCell: BaseRoundedCollectionViewCell {
    
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = AppTheme.current.tintColor
        }
    }
    @IBOutlet private var iconView: UIImageView! {
        didSet {
            iconView.tintColor = AppTheme.current.secondaryTintColor
        }
    }
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var icon: UIImage? {
        get { return iconView.image }
        set { iconView.image = newValue }
    }
    
}
