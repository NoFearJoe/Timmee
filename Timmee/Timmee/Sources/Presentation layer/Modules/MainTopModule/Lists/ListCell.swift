//
//  ListCell.swift
//  Timmee
//
//  Created by Ilya Kharabet on 06.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIView
import class UIKit.UILabel
import class UIKit.UIImageView
import class SwipeCellKit.SwipeTableViewCell

final class ListCell: SwipeTableViewCell {

    @IBOutlet fileprivate var listIconView: UIImageView!
    @IBOutlet fileprivate var listTitleLabel: UILabel!
    @IBOutlet fileprivate var selectedListIndicator: UIView!
    
    func setList(_ list: List) {
        listIconView.image = list.icon.image
        listTitleLabel.text = list.title
        
        if list is SmartList {
            listTitleLabel.textColor = AppTheme.current.specialColor
        } else {
            listTitleLabel.textColor = AppTheme.current.tintColor
        }
    }
    
    func setListSelected(_ selected: Bool) {
        selectedListIndicator.isHidden = !selected
    }

}

extension ListCell {
    
    func applyAppearance() {
        backgroundColor = AppTheme.current.foregroundColor
        listIconView.tintColor = AppTheme.current.secondaryTintColor
        selectedListIndicator.backgroundColor = AppTheme.current.blueColor
    }
    
}
