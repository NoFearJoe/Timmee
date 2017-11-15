//
//  ControlPanel.swift
//  Timmee
//
//  Created by Ilya Kharabet on 06.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UILabel
import class UIKit.UIButton
import class UIKit.UIImageView
import class UIKit.NSLayoutConstraint

final class ControlPanel: BarView {

    @IBOutlet fileprivate var listIconView: UIImageView!
    @IBOutlet fileprivate var listTitleLabel: UILabel!
    
    @IBOutlet fileprivate var settingsButton: UIButton!
    @IBOutlet fileprivate var searchButton: UIButton!
    @IBOutlet fileprivate var editButton: UIButton!
    
    @IBOutlet fileprivate var editButtonWidthConstraint: NSLayoutConstraint!
    
    func showList(_ list: List) {
        setListIcon(list.icon)
        setListTitle(list.title)
    }
    
    func setListIcon(_ icon: ListIcon) {
        listIconView.image = icon.image
    }
    
    func setListTitle(_ title: String) {
        listTitleLabel.text = title
    }
    
    func setGroupEditingButtonEnabled(_ isEnabled: Bool) {
        editButton.isEnabled = isEnabled
    }
    
    func setGroupEditingVisible(_ isVisible: Bool) {
        editButton.isHidden = !isVisible
        editButtonWidthConstraint.constant = isVisible ? 32 : 0
        layoutIfNeeded()
    }
    
    func changeGroupEditingState(to isEditing: Bool) {
        editButton.setImage(isEditing ? #imageLiteral(resourceName: "checkmark") : #imageLiteral(resourceName: "edit"), for: .normal)
        editButton.setImage(isEditing ? #imageLiteral(resourceName: "checkmark") : #imageLiteral(resourceName: "edit"), for: .disabled)
        editButton.tintColor = isEditing ? AppTheme.current.greenColor : AppTheme.current.backgroundTintColor
        
        settingsButton.isUserInteractionEnabled = !isEditing
        searchButton.isUserInteractionEnabled = !isEditing
    }

}

extension ControlPanel {
    
    func applyAppearance() {
        showShadow = false
        separatorColor = .clear
        
        barColor = .clear
        listTitleLabel.textColor = AppTheme.current.backgroundTintColor
        listIconView.tintColor = AppTheme.current.specialColor
        
        settingsButton.tintColor = AppTheme.current.backgroundTintColor
        searchButton.tintColor = AppTheme.current.backgroundTintColor
        editButton.tintColor = AppTheme.current.backgroundTintColor
    }
    
}
