//
//  TaskRepeatingEditor.swift
//  Timmee
//
//  Created by Ilya Kharabet on 26.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

protocol TaskRepeatingEditorInput: class {
    var canClear: Bool { get set }
    func setRepeatMask(_ repeatMask: RepeatMask)
    func setRepeatMasksVisible(_ isVisible: Bool)
}

protocol TaskRepeatingEditorOutput: class {
    func didSelectRepeatMask(_ repeatMask: RepeatMask)
}

protocol TaskRepeatingEditorTransitionOutput: class {
    func didAskToShowIntervalPiker(completion: @escaping  (TaskIntervalRepeatingPicker) -> Void)
    func didAskToShowWeeklyPicker(completion: @escaping  (TaskWeeklyRepeatingPicker) -> Void)
}

final class TaskRepeatingEditor: UITableViewController {
    
    var canClear: Bool = true {
        didSet { updateClearButton() }
    }
    
    weak var output: TaskRepeatingEditorOutput?
    weak var transitionOutput: TaskRepeatingEditorTransitionOutput?
    weak var container: TaskParameterEditorOutput?
    
    private var selectedMask: RepeatMask? {
        didSet {
            guard let mask = selectedMask else { return }
            if let index = repeatingTemplates.index(of: mask.type), mask.value <= 1 {
                selectedTemplateIndex = index
            } else if case .on(let unit) = mask.type, unit.isEveryday {
                selectedTemplateIndex = 1
            } else {
                selectedTemplateIndex = -1
            }
            
            if case .every = mask.type, mask.value != 1 {
                selectedCaseIndex = 0
            } else if case .on = mask.type {
                selectedCaseIndex = 0
            } else {
                selectedCaseIndex = -1
            }
            
            output?.didSelectRepeatMask(mask)
            tableView.reloadData()
        }
    }
    
    private var customRepeatingMask: RepeatMask?
    
    private var isRepeatMasksVisible: Bool = true
    
    let repeatingTemplates: [RepeatType] = [
//        RepeatType.never,
        RepeatType.every(.day),
        RepeatType.every(.week),
        RepeatType.every(.month),
        RepeatType.every(.year)
    ]
    var selectedTemplateIndex = -1
    
    let customRepeatingCases: [String] = [
//        "choose_interval".localized,
        "choose_days".localized
    ]
    var selectedCaseIndex = -1
    
    
    fileprivate static let rowHeight: CGFloat = 44
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.backgroundColor = .clear
        tableView.separatorColor = AppTheme.current.panelColor
        updateClearButton()
    }
    
    private func updateClearButton() {
        container?.closeButton.isHidden = !canClear
    }

}

extension TaskRepeatingEditor: TaskRepeatingEditorInput {

    func setRepeatMask(_ repeatMask: RepeatMask) {
        self.selectedMask = repeatMask
    }
    
    func setRepeatMasksVisible(_ isVisible: Bool) {
        self.isRepeatMasksVisible = isVisible
    }

}

extension TaskRepeatingEditor {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return isRepeatMasksVisible ? repeatingTemplates.count : 0
        }
        return customRepeatingCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskRepeatingCell", for: indexPath) as! TaskRepeatingCell
        
        if indexPath.section == 0 {
            cell.setRepeatType(repeatingTemplates[indexPath.row])
            cell.setIndicatorVisible(selectedTemplateIndex == indexPath.row)
            cell.accessoryType = .none
        } else {
            cell.setTitle(customRepeatingCases[indexPath.row])
            cell.setIndicatorVisible(selectedCaseIndex == indexPath.row)
            cell.accessoryType = .disclosureIndicator
        }
        
        cell.setupAppearance()
        
        return cell
    }

}

extension TaskRepeatingEditor {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedMask = RepeatMask(type: repeatingTemplates[indexPath.row],
                                      value: 1)
        } else {
//            if indexPath.row == 0 {
//                transitionOutput?.didAskToShowIntervalPiker(completion: { picker in
//                    picker.output = self
//                })
//            } else if indexPath.row == 1 {
                transitionOutput?.didAskToShowWeeklyPicker(completion: { picker in
                    picker.output = self
                })
//            }
        }
    }

}

extension TaskRepeatingEditor: TaskIntervalRepeatingPickerOutput {

    func didSelectInterval(_ interval: Int, unit: RepeatUnit) {
        selectedMask = RepeatMask(type: .every(unit), value: interval)
    }

}

extension TaskRepeatingEditor: TaskWeeklyRepeatingPickerOutput {

    func didSelectDays(_ days: [Int]) {
        if days.count == 0 {
            selectedMask = RepeatMask(type: .never)
        } else {
            let dayUnits = Set(days.map { DayUnit(number: $0) })
            selectedMask = RepeatMask(type: .on(.custom(dayUnits)))
        }
    }
    
    func didSelectWeekdays() {
        selectedMask = RepeatMask(type: .on(.weekdays))
    }
    
    func didSelectWeekends() {
        selectedMask = RepeatMask(type: .on(.weekends))
    }

}

extension TaskRepeatingEditor: TaskParameterEditorInput {
    
    var requiredHeight: CGFloat {
        let repeatMasksCount = isRepeatMasksVisible ? repeatingTemplates.count : 0
        return CGFloat(repeatMasksCount + customRepeatingCases.count) * TaskRepeatingEditor.rowHeight
    }
    
}


final class TaskRepeatingCell: UITableViewCell {
    
    @IBOutlet private var titleView: UILabel!
    @IBOutlet private var selectedIndicator: UIView!
    
    func setRepeatType(_ type: RepeatType) {
        titleView?.text = type.localized
    }
    
    func setTitle(_ title: String) {
        titleView.text = title
    }
    
    func setIndicatorVisible(_ isVisible: Bool) {
        selectedIndicator.isHidden = !isVisible
    }
    
    func setupAppearance() {
        titleView.textColor = AppTheme.current.tintColor
        selectedIndicator.backgroundColor = AppTheme.current.blueColor
    }
    
}
