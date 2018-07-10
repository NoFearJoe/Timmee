//
//  TableListRepresentationCompletedSectionHeaderView.swift
//  Timmee
//
//  Created by i.kharabet on 13.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class TableListRepresentationCompletedSectionHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.backgroundColor = AppTheme.current.middlegroundColor
            titleLabel.textColor = AppTheme.current.secondaryTintColor
        }
    }
    @IBOutlet private var deleteButton: UIButton! {
        didSet {
            deleteButton.backgroundColor = AppTheme.current.middlegroundColor
            deleteButton.tintColor = AppTheme.current.redColor
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var showDeleteButton: Bool = true {
        didSet {
            deleteButton.isHidden = !showDeleteButton
        }
    }
    
    var onDelete: (() -> Void)?
    
    @IBAction private func deleteButtonTap() {
        onDelete?()
    }
    
    func applyAppearance() {
        contentView.backgroundColor = .clear
        backgroundView = UIView()
    }
    
}
