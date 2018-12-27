//
//  TaskRepeatKindPicker.swift
//  Timmee
//
//  Created by i.kharabet on 24.12.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import TasksKit

final class TaskRepeatKindPicker: HiddingParameterView {
    
    var selectedRepeatKind: Task.RepeatKind = .single {
        didSet { updateUI(repeatKind: selectedRepeatKind) }
    }
    var onSelectRepeatKind: ((Task.RepeatKind) -> Void)?
    
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.text = "task_kind".localized
            titleLabel.textColor = AppTheme.current.secondaryTintColor
        }
    }
    @IBOutlet private var singleRepeatKindButton: BorderedSelectableButton! {
        didSet {
            singleRepeatKindButton.setTitle("single_task_kind".localized, for: .normal)
        }
    }
    @IBOutlet private var regularRepeatKindButton: BorderedSelectableButton! {
        didSet {
            regularRepeatKindButton.setTitle("regular_task_kind".localized, for: .normal)
        }
    }
    
    @IBAction private func onTapToSingleRepeatKindButton() {
        guard selectedRepeatKind != .single else { return }
        onSelectRepeatKind?(.single)
    }
    
    @IBAction private func onTapToRegularRepeatKindButton() {
        guard selectedRepeatKind != .regular else { return }
        onSelectRepeatKind?(.regular)
    }
    
    private func updateUI(repeatKind: Task.RepeatKind) {
        singleRepeatKindButton.isSelected = repeatKind == .single
        regularRepeatKindButton.isSelected = repeatKind == .regular
    }
    
}
