//
//  ControlPanel.swift
//  Timmee
//
//  Created by Ilya Kharabet on 06.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class ControlPanel: BarView {

    @IBOutlet fileprivate weak var listIconView: UIImageView!
    @IBOutlet fileprivate weak var listTitleLabel: UILabel!
    
    @IBOutlet fileprivate weak var settingsButton: UIButton!
    @IBOutlet fileprivate weak var searchButton: UIButton!
    @IBOutlet fileprivate weak var addListButton: UIButton!
    
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
    
    func applyAppearance() {
        showShadow = true
        
        barColor = AppTheme.current.scheme.panelColor
        listTitleLabel.textColor = AppTheme.current.scheme.tintColor
        listIconView.tintColor = AppTheme.current.scheme.specialColor
        
        settingsButton.tintColor = AppTheme.current.scheme.tintColor
        searchButton.tintColor = AppTheme.current.scheme.tintColor
        addListButton.tintColor = AppTheme.current.scheme.tintColor
    }

}
