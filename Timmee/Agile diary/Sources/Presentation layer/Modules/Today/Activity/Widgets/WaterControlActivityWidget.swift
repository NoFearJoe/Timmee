//
//  WaterControlActivityWidget.swift
//  Agile diary
//
//  Created by i.kharabet on 18.03.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import TasksKit

final class WaterControlActivityWidget: UIViewController {
    
    @IBOutlet private var containerView: CardView!
    
    @IBOutlet private var titleLabel: UILabel!
    
    @IBOutlet private var drunkVolumeLabel: UILabel!
    
    @IBOutlet private var waterLevelView: WaterLevelView!
    
    @IBOutlet private var drinkButtonsContainer: UIView!
    @IBOutlet private var drink100mlButton: UIButton!
    @IBOutlet private var drink100mlLabel: UILabel!
    @IBOutlet private var drink200mlButton: UIButton!
    @IBOutlet private var drink200mlLabel: UILabel!
    @IBOutlet private var drink300mlButton: UIButton!
    @IBOutlet private var drink300mlLabel: UILabel!
    
    @IBOutlet private var placeholderContainer: UIView!
    @IBOutlet private var waterControlConfigurationButton: UIButton!
    @IBOutlet private var waterControlReconfigurationButton: UIButton!
    
    private let placeholderView = PlaceholderView.loadedFromNib()
    
    private let waterControlService = ServicesAssembly.shared.waterControlService
    
    private lazy var waterControlLoader = WaterControlLoader(provider: waterControlService)
    
    var sprint: Sprint?
    
    private var waterControl: WaterControl? {
        didSet {
            updateWaterControlUI()
        }
    }
    
    @IBAction private func onTapToDrinkButton(_ button: UIButton) {
        switch button {
        case drink100mlButton: addDrunkVolume(milliliters: 100)
        case drink200mlButton: addDrunkVolume(milliliters: 200)
        case drink300mlButton: addDrunkVolume(milliliters: 300)
        default: return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialState()
        setupPlaceholder()
        titleLabel.text = "water_control_widget_title".localized
        drink100mlLabel.text = "+100ml".localized
        drink200mlLabel.text = "+200ml".localized
        drink300mlLabel.text = "+300ml".localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAppearance()
        
        waterLevelView.animationHasStoped = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        waterLevelView.animationHasStoped = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowWaterControlConfiguration" {
            guard let navigationController = segue.destination as? UINavigationController, let viewController = navigationController.viewControllers.first as? WaterControlConfigurationViewController else { return }
            viewController.sprint = sprint
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func setupAppearance() {
        containerView.setupAppearance()
        setupWaterControlConfigurationButton()
        titleLabel.font = AppTheme.current.fonts.medium(20)
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        waterLevelView.backgroundColor = AppTheme.current.colors.decorationElementColor
        waterControlReconfigurationButton.tintColor = AppTheme.current.colors.mainElementColor
        placeholderView.titleLabel.textColor = AppTheme.current.textColorForTodayLabelsOnBackground
        placeholderView.subtitleLabel.textColor = AppTheme.current.textColorForTodayLabelsOnBackground
        drunkVolumeLabel.font = AppTheme.current.fonts.bold(32)
        drunkVolumeLabel.textColor = AppTheme.current.textColorForTodayLabelsOnBackground
        [drink100mlLabel, drink200mlLabel, drink300mlLabel].forEach {
            $0?.textColor = AppTheme.current.textColorForTodayLabelsOnBackground
            $0?.font = AppTheme.current.fonts.medium(12)
        }
    }
    
}

extension WaterControlActivityWidget: ActivityWidget {
    
    func refresh() {
        reloadWaterControl()
    }
    
}

extension WaterControlActivityWidget: StaticHeightStackChidController {
    
    var height: CGFloat {
        return 288
    }
    
}

private extension WaterControlActivityWidget {
    
    func reloadWaterControl() {
        guard let sprint = sprint else { return }
        
        waterControlLoader.loadWaterControl(sprintID: sprint.id) { state in
            switch state {
            case .notConfigured:
                showPlaceholder()
                waterLevelView.isHidden = true
                waterControlConfigurationButton.isHidden = false
                waterControlReconfigurationButton.isHidden = true
                setDrinkWaterButtonsVisible(false)
                drunkVolumeLabel.isHidden = true
            case let .configured(waterControl):
                hidePlaceholder()
                self.waterControl = waterControl
                waterLevelView.isHidden = false
                waterControlConfigurationButton.isHidden = true
                waterControlReconfigurationButton.isHidden = true
                setDrinkWaterButtonsVisible(true)
                drunkVolumeLabel.isHidden = false
            case let .outdated(waterControl):
                hidePlaceholder()
                self.waterControl = waterControl
                waterLevelView.isHidden = false
                waterControlConfigurationButton.isHidden = true
                waterControlReconfigurationButton.isHidden = false
                setDrinkWaterButtonsVisible(true)
                drunkVolumeLabel.isHidden = false
            }
        }
    }
    
    func updateWaterControlUI() {
        guard let waterControl = waterControl else { return }
        let todayDrunkVolume = waterControl.drunkVolume[Date.now.startOfDay] ?? 0
        let todayDrunkVolumeInLiters = WaterVolumeCalculator.roundWaterWolume(volume: todayDrunkVolume)
        let neededVolume = WaterVolumeCalculator.roundWaterWolume(volume: waterControl.neededVolume)
        drunkVolumeLabel.text =
            "\(todayDrunkVolumeInLiters)"
            + "l".localized
            + " "
            + "of".localized
            + " "
            + "\(neededVolume)"
            + "l".localized
        
        let drunkWaterInPercents = min(1, CGFloat(todayDrunkVolume).safeDivide(by: CGFloat(waterControl.neededVolume)))
        waterLevelView.waterLevel = drunkWaterInPercents
    }
    
    func addDrunkVolume(milliliters: Int) {
        guard let waterControl = waterControl else { return }
        let todayDrunkVolume = waterControl.drunkVolume[Date.now.startOfDay] ?? 0
        waterControl.drunkVolume[Date.now.startOfDay] = todayDrunkVolume + milliliters
        waterControlService.createOrUpdateWaterControl(waterControl) { [weak self] in
            self?.updateWaterControlUI()
        }
    }
    
    func setDrinkWaterButtonsVisible(_ isVisible: Bool) {
        drinkButtonsContainer.isHidden = !isVisible
    }
    
}

private extension WaterControlActivityWidget {
    
    func setInitialState() {
        waterControlConfigurationButton.isHidden = true
        waterControlReconfigurationButton.isHidden = true
        setDrinkWaterButtonsVisible(false)
    }
    
    func setupWaterControlConfigurationButton() {
        waterControlConfigurationButton.setTitle("configure_water_control".localized, for: .normal)
        waterControlConfigurationButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        waterControlConfigurationButton.setTitleColor(.white, for: .normal)
    }
    
    func setupPlaceholder() {
        placeholderView.setup(into: placeholderContainer)
        placeholderView.backgroundColor = .clear
        placeholderView.titleLabel.font = AppTheme.current.fonts.medium(18)
        placeholderView.subtitleLabel.font = AppTheme.current.fonts.regular(14)
        placeholderContainer.isHidden = true
    }
    
    func showPlaceholder() {
        placeholderContainer.isHidden = false
        placeholderView.icon = UIImage(imageLiteralResourceName: "glass300ml")
        placeholderView.title = "water_control_not_initialized".localized
        placeholderView.subtitle = nil
    }
    
    func hidePlaceholder() {
        placeholderContainer.isHidden = true
    }
    
}

private class WaterControlLoader {
    
    enum WaterControlConfigurationState {
        case notConfigured
        case configured(WaterControl)
        case outdated(WaterControl)
    }
    
    unowned let provider: WaterControlProvider
    
    init(provider: WaterControlProvider) {
        self.provider = provider
    }
    
    func loadWaterControl(sprintID: String, completion: (WaterControlConfigurationState) -> Void) {
        let waterControl = provider.fetchWaterControl()
        if let waterControl = waterControl {
            if waterControl.lastConfiguredSprintID == sprintID {
                completion(.configured(waterControl))
            } else {
                completion(.outdated(waterControl))
            }
        } else {
            completion(.notConfigured)
        }
    }
    
}

