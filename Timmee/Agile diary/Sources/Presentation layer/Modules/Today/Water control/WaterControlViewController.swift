//
//  WaterControlViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 21.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class WaterControlViewController: UIViewController {
    
    weak var progressListener: TodayViewSectionProgressListener?
    
    @IBOutlet private var placeholderContainer: UIView!
    @IBOutlet private var waterControlConfigurationButton: UIButton!
    
    private let placeholderView = PlaceholderView.loadedFromNib()
    
    private let waterControlService = ServicesAssembly.shared.waterControlService
    
    private lazy var waterControlLoader = WaterControlLoader(provider: waterControlService)
    
    var sprint: Sprint!
    
    private var waterControl: WaterControl? {
        didSet {
            updateWaterControlUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialState()
        setupPlaceholder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAppearance()
        
        updateProgress()
        
        waterControlLoader.loadWaterControl(sprintID: sprint.id) { state in
            switch state {
            case .notConfigured:
                showPlaceholder()
                waterControlConfigurationButton.isHidden = false
            case let .configured(waterControl):
                hidePlaceholder()
                self.waterControl = waterControl
                waterControlConfigurationButton.isHidden = true
            case let .outdated(waterControl):
                hidePlaceholder()
                self.waterControl = waterControl
                waterControlConfigurationButton.isHidden = true 
            }
        }
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
        setupWaterControlConfigurationButton()
    }
    
}

private extension WaterControlViewController {
    
    func updateWaterControlUI() {
        guard let waterControl = waterControl else { return }
        let todayDrunkVolume = waterControl.drunkVolume[Date().startOfDay] ?? 0
        print(todayDrunkVolume)
    }
    
    func updateProgress() {
        progressListener?.didChangeProgress(for: .water, to: 0)
    }
    
}

private extension WaterControlViewController {
    
    func setInitialState() {
        waterControlConfigurationButton.isHidden = true
    }
    
    func setupWaterControlConfigurationButton() {
        waterControlConfigurationButton.setTitle("configure_water_control".localized, for: .normal)
        waterControlConfigurationButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        waterControlConfigurationButton.setTitleColor(AppTheme.current.colors.foregroundColor, for: .normal)
    }
    
    func setupPlaceholder() {
        placeholderView.setup(into: placeholderContainer)
        placeholderView.titleLabel.font = UIFont.avenirNextMedium(18)
        placeholderView.subtitleLabel.font = UIFont.avenirNextRegular(14)
        placeholderContainer.isHidden = true
    }
    
    func showPlaceholder() {
        placeholderContainer.isHidden = false
        placeholderView.icon = nil // TODO: Add icon
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
