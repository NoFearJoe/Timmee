//
//  TasksImportCell.swift
//  Timmee
//
//  Created by Ilya Kharabet on 01.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class TasksImportCell: UITableViewCell {

    @IBOutlet fileprivate weak var checkBox: CheckBox!
    @IBOutlet fileprivate weak var containerView: UIView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var isChecked: Bool {
        get { return checkBox.isChecked }
        set {
            if isChecked != newValue {
                checkBox.isChecked = newValue
            }
        }
    }
    
    var isDone: Bool = false {
        didSet {
            titleLabel.textColor = AppTheme.current.scheme.cellTintColor.withAlphaComponent(isDone ? 0.5 : 1)
            titleLabel.numberOfLines = isDone ? 1 : 2
        }
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.backgroundColor = AppTheme.current.scheme.cellBackgroundColor
        titleLabel.textColor = AppTheme.current.scheme.cellTintColor
    }

}
