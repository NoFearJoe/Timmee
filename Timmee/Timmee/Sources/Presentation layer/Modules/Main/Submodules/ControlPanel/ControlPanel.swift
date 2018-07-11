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
    
    private var isControlsHidden = false
    
    private var isGroupEditingAvailable = false
    private var isGroupEditing = false
    
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
        editButton.alpha = isVisible ? 1 : 0
        isGroupEditingAvailable = isVisible
    }
    
    func changeGroupEditingState(to isEditing: Bool) {
        editButton.setImage(isEditing ? #imageLiteral(resourceName: "checkmark") : #imageLiteral(resourceName: "edit"), for: .normal)
        editButton.setImage(isEditing ? #imageLiteral(resourceName: "checkmark") : #imageLiteral(resourceName: "edit"), for: .disabled)
        editButton.tintColor = isEditing ? AppTheme.current.greenColor : AppTheme.current.backgroundTintColor
        isGroupEditing = isEditing
    }
    
    func setNotGroupEditingControlsHidden(_ isHidden: Bool) {
        UIView.animate(withDuration: 0.33,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {
                        [self.settingsButton, self.searchButton].forEach {
                            $0?.isHidden = isHidden
                            $0?.alpha = isHidden ? 0 : 1
                        }
                           self.layoutIfNeeded()
        }, completion: nil)
    }
    
    func showControls(animated: Bool) {
        guard isControlsHidden else { return }
        
        controlsToChangeVisibility.forEach { $0.isHidden = false }
        
        if animated {
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [.beginFromCurrentState, .curveEaseOut],
                           animations:
            {
                self.controlsToChangeVisibility.forEach { $0.alpha = 1 }
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
                self.controlsToChangeVisibility.forEach { $0.alpha = 0 }
            }, completion: { _ in
                self.controlsToChangeVisibility.forEach { $0.isHidden = true }
                self.isControlsHidden = true
            })
        } else {
            controlsToChangeVisibility.forEach { $0.isHidden = true }
            isControlsHidden = true
        }
    }
    
    private var controlsToChangeVisibility: [UIButton] {
        if isGroupEditingAvailable {
            if isGroupEditing {
                return [editButton]
            }
            return [settingsButton, searchButton, editButton]
        }
        return [settingsButton, searchButton]
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
