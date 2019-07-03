//
//  ListCollectionViewCell.swift
//  Timmee
//
//  Created by i.kharabet on 30.01.18.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class ListCollectionViewCell: SwipableCollectionViewCell {
    
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
    @IBOutlet private var tasksCountLabel: UILabel! {
        didSet {
            tasksCountLabel.backgroundColor = AppTheme.current.panelColor
            tasksCountLabel.textColor = AppTheme.current.secondaryTintColor
        }
    }
    @IBOutlet var favoritePicker: TaskImportancyPicker! {
        didSet {
            favoritePicker.changeStateAutomatically = false
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
    
    var tasksCount: String? {
        get { return tasksCountLabel.text }
        set {
            tasksCountLabel.text = newValue
            tasksCountLabel.isHidden = newValue == nil || newValue == ""
        }
    }
    
    var isFavorite: Bool {
        get { return favoritePicker.isPicked }
        set { favoritePicker.isPicked = newValue }
    }
    
    var shouldShowFavoritePicker: Bool = false {
        didSet {
            favoritePicker.isHidden = !shouldShowFavoritePicker
        }
    }
    
    var isPicked: Bool = false {
        didSet {
            titleLabel.textColor = isPicked ? AppTheme.current.blueColor : AppTheme.current.tintColor
            titleLabel.font = isPicked ? UIFont.systemFont(ofSize: 16, weight: .medium) : UIFont.systemFont(ofSize: 16)
        }
    }
    
    var isActive: Bool = true {
        didSet {
            isUserInteractionEnabled = isActive
            alpha = isActive ? 1 : 0.5
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = AppTheme.current.foregroundColor
        configureShadow(radius: 4, opacity: 0.1)
    }
    
}
