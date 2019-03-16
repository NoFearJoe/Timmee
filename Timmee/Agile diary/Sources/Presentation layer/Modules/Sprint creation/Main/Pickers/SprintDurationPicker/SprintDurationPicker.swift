//
//  SprintDurationPicker.swift
//  Agile diary
//
//  Created by i.kharabet on 14.03.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import UIComponents

protocol SprintDurationPickerInput: AnyObject {
    func setSprintDuration(_ duration: Int)
}

protocol SprintDurationPickerDelegate: AnyObject {
    func sprintDurationPicker(_ picker: SprintDurationPicker, didSelectSprintDuration duration: Int)
}

final class SprintDurationPicker: UIViewController, SprintDurationPickerInput {
    
    weak var delegate: SprintDurationPickerDelegate?
    
    @IBOutlet private var sprintDurationSwitcher: Switcher!
    @IBOutlet private var subtitleLabel: UILabel!
    
    @IBAction private func onSprintDurationSwitcherValueChanged() {
        guard let duration = Constants.sprintDurations.item(at: sprintDurationSwitcher.selectedItemIndex) else { return }
        delegate?.sprintDurationPicker(self, didSelectSprintDuration: duration)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "sprint_duration_picker_title".localized
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.title = "sprint_duration_picker_title".localized
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sprintDurationSwitcher.items = SprintDurationPicker.makeSwitcherItems()
        subtitleLabel.text = "in_weeks".localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subtitleLabel.font = AppTheme.current.fonts.regular(12)
        subtitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        sprintDurationSwitcher.setupAppearance()
    }
    
    func setSprintDuration(_ duration: Int) {
        sprintDurationSwitcher.selectedItemIndex = Constants.sprintDurations.index(of: duration) ?? 0
    }
    
    private static func makeSwitcherItems() -> [SwitcherItem] {
        return Constants.sprintDurations.map { "\($0)" }
    }
    
}

extension SprintDurationPicker: EditorInput {
    
    var requiredHeight: CGFloat {
        return 72
    }
    
}
