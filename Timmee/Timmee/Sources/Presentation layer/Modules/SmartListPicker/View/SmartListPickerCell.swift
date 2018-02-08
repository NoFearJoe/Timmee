//
//  SmartListPickerCell.swift
//  Timmee
//
//  Created by i.kharabet on 08.02.18.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class SmartListPickerCell: BaseRoundedCollectionViewCell {
    
    @IBOutlet private var iconView: UIImageView! {
        didSet {
            iconView.tintColor = AppTheme.current.secondaryTintColor
        }
    }
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = AppTheme.current.tintColor
        }
    }
    @IBOutlet private var checkBox: CheckBox!
    
    var icon: UIImage? {
        get { return iconView.image }
        set { iconView.image = newValue }
    }
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var isPicked: Bool = false {
        didSet {
            checkBox.isChecked = isPicked
        }
    }
    
}
