//
//  SprintNotificationTimePicker.swift
//  Agile diary
//
//  Created by i.kharabet on 19.11.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

protocol SprintNotificationTimePickerInput: class {
    func setNotificationsEnabled(_ isEnabled: Bool)
    func setNotificationsDays(_ days: [DayUnit])
    func setNotificationsTime(_ time: (Int, Int))
}

protocol SprintNotificationTimePickerOutput: class {
    func didSetNotificationsEnabled(_ isEnabled: Bool)
    func didChangeNotificationsDays(_ days: [DayUnit])
    func didChangeNotificationsTime(_ time: (Int, Int))
}

final class SprintNotificationTimePicker: UIViewController {
    
    weak var output: SprintNotificationTimePickerOutput?
    
    @IBOutlet private var enableNotificationLabel: UILabel!
    @IBOutlet private var enableNotificationCheckbox: Checkbox!
    @IBOutlet private var notificationsDaysTitleLabel: UILabel!
    @IBOutlet private var notificationsDaysButtons: [SelectableButton]!
    @IBOutlet private var notificationTimeLabel: UILabel!
    
    @IBOutlet private var notificationTimePickerContainer: UIView!
    private var notificationTimePicker: NotificationTimePicker!
    
    private var isNotificationsEnabled: Bool = false
    private var days: [DayUnit] = []
    private var hours: Int = 0
    private var minutes: Int = 0
    
    @IBAction private func onSelectDay(_ button: UIButton) {
        button.isSelected = !button.isSelected
        updateSprintNotificationsDays()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.title = "sprint_notifications".localized
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.title = "sprint_notifications".localized
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableNotificationLabel.text = "reminder".localized
        notificationsDaysTitleLabel.text = "sprint_notification_days_title".localized
        notificationTimeLabel.text = "sprint_notification_time_title".localized
        enableNotificationCheckbox.didChangeCkeckedState = { [unowned self] isChecked in
            self.isNotificationsEnabled = isChecked
            self.updateUIForNotificationsEnabledState(isChecked)
            self.output?.didSetNotificationsEnabled(isChecked)
        }
        notificationsDaysButtons.forEach { $0.isSelected = false }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enableNotificationLabel.font = AppTheme.current.fonts.regular(17)
        enableNotificationLabel.textColor = AppTheme.current.colors.inactiveElementColor
        notificationsDaysTitleLabel.font = AppTheme.current.fonts.regular(17)
        notificationsDaysTitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        notificationTimeLabel.font = AppTheme.current.fonts.regular(17)
        notificationTimeLabel.textColor = AppTheme.current.colors.inactiveElementColor
        setupNotificationsDaysButtonsAppearance()
        updateNotificationsDaysButtons()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedNotificationTimePicker" {
            guard let picker = segue.destination as? NotificationTimePicker else { return }
            picker.output = self
            notificationTimePicker = picker
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
}

extension SprintNotificationTimePicker: SprintNotificationTimePickerInput {
    
    func setNotificationsEnabled(_ isEnabled: Bool) {
        isNotificationsEnabled = isEnabled
        updateUIForNotificationsEnabledState(isEnabled)
    }
    
    func setNotificationsDays(_ days: [DayUnit]) {
        self.days = days
        updateNotificationsDaysButtons()
    }
    
    func setNotificationsTime(_ time: (Int, Int)) {
        hours = time.0
        minutes = time.1
        updateNotificationsTime()
    }
    
}

extension SprintNotificationTimePicker: NotificationTimePickerOutput {
    
    func didChangeHours(to hours: Int) {
        self.hours = hours
        output?.didChangeNotificationsTime((self.hours, self.minutes))
    }
    
    func didChangeMinutes(to minutes: Int) {
        self.minutes = minutes
        output?.didChangeNotificationsTime((self.hours, self.minutes))
    }
    
}

extension SprintNotificationTimePicker: EditorInput {
    
    var requiredHeight: CGFloat {
        return 252
    }
    
}

private extension SprintNotificationTimePicker {
    
    func updateUIForNotificationsEnabledState(_ isEnabled: Bool) {
        enableNotificationCheckbox.isChecked = isEnabled
        notificationTimePickerContainer.isUserInteractionEnabled = isEnabled
        notificationTimePickerContainer.alpha = isEnabled ? AppTheme.current.style.alpha.enabled : AppTheme.current.style.alpha.disabled
        notificationsDaysButtons.forEach {
            $0.isUserInteractionEnabled = isEnabled
            $0.alpha = isEnabled ? AppTheme.current.style.alpha.enabled : AppTheme.current.style.alpha.disabled
        }
    }
    
}

private extension SprintNotificationTimePicker {
    
    func setupNotificationsDaysButtonsAppearance() {
        notificationsDaysButtons.forEach {
            $0.selectedBackgroundColor = $0.tag < 5 ? AppTheme.current.colors.mainElementColor : AppTheme.current.colors.wrongElementColor
            $0.defaultBackgroundColor = AppTheme.current.colors.decorationElementColor
            $0.tintColor = .clear
            $0.setTitleColor(AppTheme.current.colors.activeElementColor, for: .normal)
            $0.setTitleColor(UIColor.white, for: .selected)
            $0.setTitleColor(UIColor.white, for: .highlighted)
        }
    }
    
    func updateNotificationsDaysButtons() {
        notificationsDaysButtons.forEach {
            $0.setTitle(DayUnit(number: $0.tag).localizedShort, for: .normal)
            $0.isSelected = days.map { $0.number }.contains($0.tag)
        }
    }
    
    func updateSprintNotificationsDays() {
        days = notificationsDaysButtons.filter { $0.isSelected }.map { DayUnit(number: $0.tag) }
        output?.didChangeNotificationsDays(days)
    }
    
}

private extension SprintNotificationTimePicker {
    
    func updateNotificationsTime() {
        notificationTimePicker.setHours(hours)
        notificationTimePicker.setMinutes(minutes)
    }
    
}
