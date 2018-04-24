//
//  ControlPanel.swift
//  Timmee
//
//  Created by Ilya Kharabet on 06.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIView
import class UIKit.UILabel
import class UIKit.UIButton
import class UIKit.UIImageView
import class UIKit.NSLayoutConstraint

final class ControlPanel: BarView {

    @IBOutlet private var listIconView: UIImageView!
    @IBOutlet private var listTitleLabel: UILabel!
    
    @IBOutlet private var settingsButton: UIButton!
    @IBOutlet private var searchButton: UIButton!
    @IBOutlet private var editButton: UIButton!
    
    @IBOutlet private var editButtonWidthConstraint: NSLayoutConstraint!
    
    private var isControlsHidden = false
    
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
        
        settingsButton.isEnabled = !isEditing
        searchButton.isEnabled = !isEditing
    }
    
    func showControls(animated: Bool) {
        guard isControlsHidden else { return }
        
        [settingsButton, searchButton, editButton].forEach { $0?.isHidden = false }
        
        if animated {
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [.beginFromCurrentState, .curveEaseOut],
                           animations:
            {
                [self.settingsButton, self.searchButton, self.editButton].forEach { $0?.alpha = 1 }
            }, completion: { _ in
                self.isControlsHidden = false
            })
        } else {
            isControlsHidden = false
        }
    }
    
    func hideControls(animated: Bool) {
        guard !isControlsHidden else { return }
        
        if animated {
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [.beginFromCurrentState, .curveEaseIn],
                           animations:
            {
                [self.settingsButton, self.searchButton, self.editButton].forEach { $0?.alpha = 0 }
            }, completion: { _ in
                [self.settingsButton, self.searchButton, self.editButton].forEach { $0?.isHidden = true }
                self.isControlsHidden = true
            })
        } else {
            [settingsButton, searchButton, editButton].forEach { $0?.isHidden = true }
            isControlsHidden = true
        }
    }

}

extension ControlPanel {
    
    func applyAppearance() {
        showShadow = false
        
        backgroundColor = .clear
        listTitleLabel.textColor = AppTheme.current.backgroundTintColor
        listIconView.tintColor = AppTheme.current.specialColor
        
        settingsButton.tintColor = AppTheme.current.backgroundTintColor
        searchButton.tintColor = AppTheme.current.backgroundTintColor
        editButton.tintColor = AppTheme.current.backgroundTintColor
    }
    
}
