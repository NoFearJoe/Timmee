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
    
    private var containerViews: [UIView] {
        return [dailyWaterVolumeContainerView, genderContainerView, weightContainerView, activityContainerView, notificationsContainerView]
    }
    
    private var titleLabels: [UILabel] {
        return [dailyWaterVolumeTitleLabel, genderTitleLabel, weightTitleLabel, activityTitleLabel, notificationsTitleLabel]
    }
    
    private var gender: Gender = .male {
        didSet { updateNeededWaterVolume() }
    }
    private var weight: Int = 65 {
        didSet { updateNeededWaterVolume() }
    }
    private var activity: Activity = .medium {
        didSet { updateNeededWaterVolume() }
    }
    
    @IBAction private func onClose() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        genderSwitcher.items = [Gender.male.title, Gender.female.title]
        genderSwitcher.selectedItemIndex = 0
        genderSwitcher.addTarget(self, action: #selector(onSwitchGender), for: .touchUpInside)
        
        activitySwitcher.items = [Activity.low.title, Activity.medium.title, Activity.high.title]
        activitySwitcher.selectedItemIndex = 1
        activitySwitcher.addTarget(self, action: #selector(onSwitchActivity), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onChangeWeight),
                                               name: NSNotification.Name.UITextFieldTextDidChange,
                                               object: weightField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateWeightField()
        updateNeededWaterVolume()
    }
    
    @objc private func onSwitchGender() {
        gender = Gender(rawValue: genderSwitcher.selectedItemIndex) ?? .male
    }
    
    @objc private func onSwitchActivity() {
        activity = Activity(rawValue: activitySwitcher.selectedItemIndex) ?? .low
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        contentView.backgroundColor = .clear
        genderSwitcher.setupAppearance()
        activitySwitcher.setupAppearance()
        weightField.textColor = AppTheme.current.colors.mainElementColor
        weightField.font = AppTheme.current.fonts.bold(24)
        weightField.borderStyle = .none
        titleLabels.forEach { label in
            label.textColor = AppTheme.current.colors.inactiveElementColor
            label.font = AppTheme.current.fonts.medium(20)
        }
        containerViews.forEach { container in
            container.configureShadow(radius: 4, opacity: 0.1)
            container.backgroundColor = AppTheme.current.colors.foregroundColor
        }
    }
    
    private func updateWeightField() {
        weightField.text = "\(weight)"
    }
    
    @objc private func onChangeWeight() {
        guard let text = weightField.text else { return }
        weight = Int(text) ?? 0
    }
    
    private func updateNeededWaterVolume() {
        let fullNeededVolume = WaterVolumeCalculator.calculateNeededWaterVolume(gender: gender, weight: weight, activity: activity).full
        let neededVolume = WaterVolumeCalculator.calculatePureNeededWaterVolume(waterVolume: fullNeededVolume)
        let neededVolumeInLiters = Double(neededVolume - neededVolume % 100) / 1000
        dailyWaterVolumeLabel.text = "\(neededVolumeInLiters)" + "l".localized
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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

private final class WaterVolumeCalculator {
    
    static func calculateNeededWaterVolume(gender: Gender, weight: Int, activity: Activity) -> (rest: Milliliters, full: Milliliters) {
        let restVaterVolume = weight * gender.waterVolumePerKilogram
        let fullWaterVolume = restVaterVolume + Int(activity.averageTrainingHoursPerDay * Double(gender.waterVolumePerTrainingHour))
        return (restVaterVolume, fullWaterVolume)
    }
    
    static func calculatePureNeededWaterVolume(waterVolume: Milliliters) -> Milliliters {
        return Int(Double(waterVolume) * 0.8)
    }
    
}
