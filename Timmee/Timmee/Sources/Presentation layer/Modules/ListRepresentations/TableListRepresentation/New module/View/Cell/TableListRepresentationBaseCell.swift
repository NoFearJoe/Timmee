//
//  TableListRepresentationBaseCell.swift
//  Timmee
//
//  Created by i.kharabet on 13.07.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

class TableListRepresentationBaseCell: SwipeTableViewCell, Customizable {
    
    @IBOutlet var containerView: TableListRepersentationCellContainerView!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet private var checkBox: CheckBox! {
        didSet {
            checkBox.didChangeCkeckedState = { [unowned self] isChecked in
                self.onCheck?(isChecked)
            }
        }
    }
    
    @IBOutlet private var containerViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var containerViewTrailingConstraint: NSLayoutConstraint!
    
    private var _isGroupEditing: Bool = false
    func setGroupEditing(_ isGroupEditing: Bool,
                         animated: Bool = false,
                         completion: (() -> Void)? = nil) {
        guard isGroupEditing != _isGroupEditing else { return }
        
        _isGroupEditing = isGroupEditing
        
        containerView.isUserInteractionEnabled = !isGroupEditing
        
        containerViewLeadingConstraint.constant = isGroupEditing ? 44 : 8
        containerViewTrailingConstraint.constant = isGroupEditing ? -28 : 8
        
        if animated {
            if isGroupEditing {
                checkBox.isHidden = false
            }
            
            UIView.animate(withDuration: 0.33, animations: {
                self.contentView.layoutIfNeeded()
            }) { finished in
                if finished && !isGroupEditing {
                    self.checkBox.isHidden = true
                }
                completion?()
            }
        } else {
            checkBox.isHidden = !isGroupEditing
            contentView.layoutIfNeeded()
            completion?()
        }
    }
    
    var isChecked: Bool = false {
        didSet {
            checkBox.isChecked = isChecked
        }
    }
    
    var onCheck: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyAppearance()
        checkBox.isHidden = true
    }
    
    func setTask(_ task: Task) {
        self.titleLabel.text = task.title
    }
    
    func applyAppearance() {
        contentView.backgroundColor = .clear
        containerView.fillColor = AppTheme.current.foregroundColor
        containerView.alpha = 0.6
        containerView.setNeedsDisplay()
        titleLabel.textColor = AppTheme.current.tintColor
    }
    
}
