//
//  WaterControlConfigurationViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 21.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import UIComponents

final class WaterControlConfigurationViewController: BaseViewController {
    
    // MARK: Required dependencies
    
    var sprint: Sprint!
    
    // MARK: - Outlets
    
    @IBOutlet private var contentView: UIView!
    
    @IBOutlet private var dailyWaterVolumeContainerView: UIView!
    @IBOutlet private var dailyWaterVolumeTitleLabel: UILabel!
    @IBOutlet private var dailyWaterVolumeLabel: UILabel!
    
    @IBOutlet private var genderContainerView: UIView!
    @IBOutlet private var genderTitleLabel: UILabel!
    @IBOutlet private var genderSwitcher: Switcher!
    
    @IBOutlet private var weightContainerView: UIView!
    @IBOutlet private var weightTitleLabel: UILabel!
    @IBOutlet private var weightField: UITextField!
    
    @IBOutlet private var activityContainerView: UIView!
    @IBOutlet private var activityTitleLabel: UILabel!
    @IBOutlet private var activitySwitcher: Switcher!
    
    @IBOutlet private var notificationsContainerView: UIView!
    @IBOutlet private var notificationsTitleLabel: UILabel!
    @IBOutlet private var notificationsSwitcher: Switcher!
    @IBOutlet private var notificationsIntervalTitleLabel: UILabel!
    @IBOutlet private var notificationsIntervalSwitcher: Switcher!
    @IBOutlet private var notificationsStartTimeTitleLabel: UILabel!
    @IBOutlet private var notificationsEndTimeTitleLabel: UILabel!
    @IBOutlet private var notificationsStartTimeContainer: UIView!
    @IBOutlet private var notificationsEndTimeContainer: UIView!
    
    @IBOutlet private var doneButton: UIButton!
    
    private var startNotificationTimePicker: NotificationTimePickerInput!
    private var endNotificationTimePicker: NotificationTimePickerInput!
    
    private lazy var startNotificationsTimeHandler = NotificationsTimeHandler(date: notificationsStartDate)
    private lazy var endNotificationsTimeHandler = NotificationsTimeHandler(date: notificationsEndDate)
    
    private var containerViews: [UIView] {
        return [dailyWaterVolumeContainerView, genderContainerView, weightContainerView, activityContainerView, notificationsContainerView]
    }
    
    private var titleLabels: [UILabel] {
        return [dailyWaterVolumeTitleLabel, genderTitleLabel, weightTitleLabel, activityTitleLabel, notificationsTitleLabel, notificationsStartTimeTitleLabel, notificationsEndTimeTitleLabel]
    }
    
    // MARK: - Services
    
    private let waterControlService = ServicesAssembly.shared.waterControlService
    
    // MARK: - State properties
    
    private var gender: Gender = .male {
        didSet { updateNeededWaterVolume() }
    }
    private var weight: Int = 65 {
        didSet { updateNeededWaterVolume() }
    }
    private var activity: Activity = .medium {
        didSet { updateNeededWaterVolume() }
    }
    
    private var notificationsEnabled: Bool = false {
        didSet {
            updateNotificationsAvailability()
        }
    }
    private var notificationsInterval: Int = 2
    
    private var notificationsStartDate: Date = {
        var date = Date.now
        date => 8.asHours
        return date.startOfHour
    }()
    
    private var notificationsEndDate: Date = {
        var date = Date.now
        date => 22.asHours
        return date.startOfHour
    }()
    
    // MARK: - Actions
    
    @IBAction private func onDone() {
        let waterControl = makeWaterControlModel()
        waterControlService.createOrUpdateWaterControl(waterControl) { [weak self] in
            guard let `self` = self else { return }
            WaterControlSchedulerService().scheduleWaterControl(waterControl,
                                                                startDate: self.sprint.startDate,
                                                                endDate: self.sprint.endDate)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction private func onClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func onTapToBackground() {
        view.endEditing(true)
    }
    
    @objc private func onSwitchGender() {
        gender = Gender(rawValue: genderSwitcher.selectedItemIndex) ?? .male
    }
    
    @objc private func onSwitchActivity() {
        activity = Activity(rawValue: activitySwitcher.selectedItemIndex) ?? .low
    }
    
    @objc private func onSwitchNotifications() {
        notificationsEnabled = notificationsSwitcher.selectedItemIndex == 1
    }
    
    @objc private func onSwitchNotificationsInterval() {
        notificationsInterval = notificationsIntervalSwitcher.selectedItemIndex + 1
    }
    
    @objc private func onChangeWeight() {
        guard let text = weightField.text else { return }
        weight = Int(text) ?? 0
    }
    
    // MARK: - Lifecycle methods
    
    override func prepare() {
        super.prepare()
        
        genderSwitcher.items = [Gender.male.title, Gender.female.title]
        genderSwitcher.selectedItemIndex = 0
        genderSwitcher.addTarget(self, action: #selector(onSwitchGender), for: .touchUpInside)
        
        activitySwitcher.items = [Activity.low.title, Activity.medium.title, Activity.high.title]
        activitySwitcher.selectedItemIndex = 1
        activitySwitcher.addTarget(self, action: #selector(onSwitchActivity), for: .touchUpInside)
        
        notificationsSwitcher.items = ["notifications_disabled".localized, "notifications_enabled".localized]
        notificationsSwitcher.selectedItemIndex = 0
        notificationsSwitcher.addTarget(self, action: #selector(onSwitchNotifications), for: .touchUpInside)
        
        notificationsIntervalSwitcher.items = ["1h".localized, "2h".localized, "3h".localized, "4h".localized]
        notificationsIntervalSwitcher.selectedItemIndex = 1
        notificationsIntervalSwitcher.addTarget(self, action: #selector(onSwitchNotificationsInterval), for: .touchUpInside)
        
        dailyWaterVolumeTitleLabel.text = "daily_water_volume".localized
        genderTitleLabel.text = "gender".localized
        weightTitleLabel.text = "weight".localized
        activityTitleLabel.text = "activity".localized
        notificationsTitleLabel.text = "notifications".localized
        notificationsIntervalTitleLabel.text = "notifications_interval".localized
        notificationsStartTimeTitleLabel.text = "notifications_interval_start".localized
        notificationsEndTimeTitleLabel.text = "notifications_interval_finish".localized
        doneButton.setTitle("done".localized, for: .normal)
        
        startNotificationsTimeHandler.date = notificationsStartDate
        startNotificationsTimeHandler.onChangeDate = { [unowned self] date in
            self.notificationsStartDate = date
        }
        
        endNotificationsTimeHandler.date = notificationsEndDate
        endNotificationsTimeHandler.onChangeDate = { [unowned self] date in
            self.notificationsEndDate = date
        }
        
        startNotificationTimePicker.setHours(notificationsStartDate.hours)
        startNotificationTimePicker.setMinutes(notificationsStartDate.minutes)
        endNotificationTimePicker.setHours(notificationsEndDate.hours)
        endNotificationTimePicker.setMinutes(notificationsEndDate.minutes)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onChangeWeight),
                                               name: UITextField.textDidChangeNotification,
                                               object: weightField)
    }
    
    override func refresh() {
        super.refresh()
        
        updateWeightField()
        updateNeededWaterVolume()
        updateNotificationsAvailability()
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        
        contentView.backgroundColor = .clear
        genderSwitcher.setupAppearance()
        activitySwitcher.setupAppearance()
        notificationsSwitcher.setupAppearance()
        notificationsIntervalSwitcher.setupAppearance()
        weightField.textColor = AppTheme.current.colors.mainElementColor
        weightField.font = AppTheme.current.fonts.bold(24)
        weightField.borderStyle = .none
        weightField.keyboardAppearance = AppTheme.current.keyboardStyleForTheme
        titleLabels.forEach { label in
            label.textColor = AppTheme.current.colors.inactiveElementColor
            label.font = AppTheme.current.fonts.medium(20)
        }
        notificationsIntervalTitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        notificationsIntervalTitleLabel.font = AppTheme.current.fonts.medium(16)
        containerViews.forEach { container in
            container.configureShadow(radius: 4, opacity: 0.1)
            container.backgroundColor = AppTheme.current.colors.foregroundColor
        }
        notificationsStartTimeTitleLabel.font = AppTheme.current.fonts.medium(16)
        notificationsEndTimeTitleLabel.font = AppTheme.current.fonts.medium(16)
        doneButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbedStartNotificationsTime" {
            guard let picker = segue.destination as? NotificationTimePicker else { return }
            picker.output = startNotificationsTimeHandler
            startNotificationTimePicker = picker
        } else if segue.identifier == "EmbedEndNotificationsTime" {
            guard let picker = segue.destination as? NotificationTimePicker else { return }
            picker.output = endNotificationsTimeHandler
            endNotificationTimePicker = picker
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private methods
    
    private func updateWeightField() {
        weightField.text = "\(weight)"
    }
    
    private func updateNeededWaterVolume() {
        let fullNeededVolume = WaterVolumeCalculator.calculateNeededWaterVolume(gender: gender, weight: weight, activity: activity).full
        let neededVolume = WaterVolumeCalculator.calculatePureNeededWaterVolume(waterVolume: fullNeededVolume)
        let neededVolumeInLiters = WaterVolumeCalculator.roundWaterWolume(volume: neededVolume)
        dailyWaterVolumeLabel.text = "\(neededVolumeInLiters)" + "l".localized
    }
    
    private func updateNotificationsAvailability() {
        notificationsIntervalSwitcher.isEnabled = notificationsEnabled
        notificationsIntervalSwitcher.alpha = notificationsEnabled ? AppTheme.current.style.alpha.enabled : AppTheme.current.style.alpha.disabled
        notificationsStartTimeContainer.alpha = notificationsEnabled ? AppTheme.current.style.alpha.enabled : AppTheme.current.style.alpha.disabled
        notificationsStartTimeContainer.isUserInteractionEnabled = notificationsEnabled
        notificationsEndTimeContainer.alpha = notificationsEnabled ? AppTheme.current.style.alpha.enabled : AppTheme.current.style.alpha.disabled
        notificationsEndTimeContainer.isUserInteractionEnabled = notificationsEnabled
    }
    
    private func makeWaterControlModel() -> WaterControl {
        let fullNeededVolume = WaterVolumeCalculator.calculateNeededWaterVolume(gender: gender, weight: weight, activity: activity).full
        let neededVolume = WaterVolumeCalculator.calculatePureNeededWaterVolume(waterVolume: fullNeededVolume)
        return WaterControl(id: RandomStringGenerator.randomString(length: 16),
                            neededVolume: neededVolume,
                            drunkVolume: [:],
                            sprintID: sprint.id,
                            notificationsEnabled: notificationsEnabled,
                            notificationsInterval: notificationsInterval,
                            notificationsStartTime: notificationsStartDate,
                            notificationsEndTime: notificationsEndDate)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

private final class NotificationsTimeHandler: NotificationTimePickerOutput {
    
    var onChangeDate: ((Date) -> Void)?
    var date: Date
    
    init(date: Date) {
        self.date = date
    }
    
    func didChangeHours(to hours: Int) {
        date => hours.asHours
        onChangeDate?(date)
    }
    
    func didChangeMinutes(to minutes: Int) {
        date => minutes.asMinutes
        onChangeDate?(date)
    }
    
}

private typealias Milliliters = Int

private enum Gender: Int {
    case male = 0
    case female
    
    var title: String {
        switch self {
        case .male: return "male".localized
        case .female: return "female".localized
        }
    }
    
    var waterVolumePerKilogram: Milliliters {
        switch self {
        case .male: return 40
        case .female: return 30
        }
    }
    
    var waterVolumePerTrainingHour: Milliliters {
        switch self {
        case .male: return 600
        case .female: return 400
        }
    }
}

private enum Activity: Int {
    case low = 0
    case medium
    case high
    
    var title: String {
        switch self {
        case .low: return "activity_low".localized
        case .medium: return "activity_medium".localized
        case .high: return "activity_high".localized
        }
    }
    
    var averageTrainingHoursPerDay: Double {
        switch self {
        case .low: return 1 / 7
        case .medium: return 3 / 7
        case .high: return 6 / 7
        }
    }
}

final class WaterVolumeCalculator {
    
    fileprivate static func calculateNeededWaterVolume(gender: Gender, weight: Int, activity: Activity) -> (rest: Milliliters, full: Milliliters) {
        guard weight > 0 else { return (0, 0) }
        let restVaterVolume = weight * gender.waterVolumePerKilogram
        let fullWaterVolume = restVaterVolume + Int(activity.averageTrainingHoursPerDay * Double(gender.waterVolumePerTrainingHour))
        return (restVaterVolume, fullWaterVolume)
    }
    
    fileprivate static func calculatePureNeededWaterVolume(waterVolume: Milliliters) -> Milliliters {
        return Int(Double(waterVolume) * 0.8)
    }
    
    static func roundWaterWolume(volume: Int) -> Double {
        return round((Double(volume) / 1000) * 10) / 10
    }
    
}
