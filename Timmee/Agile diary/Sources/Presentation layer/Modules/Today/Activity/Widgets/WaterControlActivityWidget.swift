//
//  WaterControlActivityWidget.swift
//  Agile diary
//
//  Created by i.kharabet on 18.03.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import TasksKit
import UIComponents

final class WaterControlActivityWidget: UIViewController {
    
    @IBOutlet private var containerView: CardView!
    
    @IBOutlet private var titleLabel: UILabel!
    
    @IBOutlet private var drunkVolumeLabel: UILabel!
    
    @IBOutlet private var waterLevelView: WaterLevelView! {
        didSet {
            waterLevelView.backgroundColor = AppTheme.current.colors.decorationElementColor
            waterLevelView.waterColor = AppTheme.current.colors.mainElementColor.withAlphaComponent(0.35)
        }
    }
    
    @IBOutlet private var drinkButtonsContainer: UIStackView!
    private let drink100mlButton = AddWaterView(title: "+100ml".localized, image: UIImage(imageLiteralResourceName: "glass100ml"))
    private let drink200mlButton = AddWaterView(title: "+200ml".localized, image: UIImage(imageLiteralResourceName: "glass200ml"))
    private let drink300mlButton = AddWaterView(title: "+300ml".localized, image: UIImage(imageLiteralResourceName: "glass300ml"))
    
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
    
    @IBAction private func onTapToDrinkButton(_ button: UIControl) {
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
        drinkButtonsContainer.addArrangedSubview(drink100mlButton)
        drinkButtonsContainer.addArrangedSubview(drink200mlButton)
        drinkButtonsContainer.addArrangedSubview(drink300mlButton)
        drink100mlButton.addTarget(self, action: #selector(onTapToDrinkButton(_:)), for: .touchUpInside)
        drink200mlButton.addTarget(self, action: #selector(onTapToDrinkButton(_:)), for: .touchUpInside)
        drink300mlButton.addTarget(self, action: #selector(onTapToDrinkButton(_:)), for: .touchUpInside)
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
            segue.destination.presentationController?.delegate = self
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
        drunkVolumeLabel.textColor = AppTheme.current.colors.activeElementColor
        [drink100mlButton, drink200mlButton, drink300mlButton].forEach {
            $0?.setupAppearance()
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

extension WaterControlActivityWidget: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        refresh()
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

class WaterControlLoader {
    
    enum WaterControlConfigurationState {
        case notConfigured
        case configured(WaterControl)
    }
    
    unowned let provider: WaterControlProvider
    
    init(provider: WaterControlProvider) {
        self.provider = provider
    }
    
    func loadWaterControl(sprintID: String, completion: (WaterControlConfigurationState) -> Void) {
        let waterControl = provider.fetchWaterControl(sprintID: sprintID)
        if let waterControl = waterControl {
            completion(.configured(waterControl))
        } else {
            completion(.notConfigured)
        }
    }
    
}

private extension WaterControlActivityWidget {
    
    final class AddWaterView: UIControl {
        
        private let imageView: UIImageView
        private let volumeLabel: UILabel
        
        init(title: String, image: UIImage) {
            imageView = UIImageView(image: image)
            volumeLabel = UILabel(frame: .zero)
            volumeLabel.text = title
            volumeLabel.textAlignment = .center
            
            super.init(frame: .zero)
            
            addSubview(imageView)
            addSubview(volumeLabel)
        }
        
        required init?(coder aDecoder: NSCoder) { fatalError() }
        
        override func didMoveToSuperview() {
            super.didMoveToSuperview()
            setupConstraints()
        }
        
        func setupAppearance() {
            volumeLabel.textColor = AppTheme.current.colors.activeElementColor
            volumeLabel.font = AppTheme.current.fonts.medium(12)
        }
        
        private func setupConstraints() {
            [imageView.leading(), imageView.trailing(), imageView.top()].toSuperview()
            [volumeLabel.leading(), volumeLabel.trailing(), volumeLabel.bottom()].toSuperview()
            
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1).isActive = true
            imageView.bottomToTop(-2).to(volumeLabel, addTo: self)
        }
        
    }
    
}
