//
//  TodayExtensionViewController.swift
//  WaterControlTodayExtension
//
//  Created by Илья Харабет on 20/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import NotificationCenter
import UIComponents
import TasksKit

class TodayExtensionViewController: UIViewController, NCWidgetProviding, SprintInteractorTrait {
    
    let sprintsService = ServicesAssembly.shared.sprintsService
    private let waterControlService = ServicesAssembly.shared.waterControlService
    
    private lazy var waterControlLoader = WaterControlLoader(provider: waterControlService)
    
    private var waterControl: WaterControl? {
        didSet {
            updateWaterControlUI()
        }
    }
    
    @IBOutlet private var waterLevelView: WaterLevelView! {
        didSet {
            waterLevelView.backgroundColor = UIColor(rgba: "E9E9E9").withAlphaComponent(0.5)
            waterLevelView.waterColor = UIColor(rgba: "29C3FE").withAlphaComponent(0.5)
        }
    }
    
    @IBOutlet private var drunkVolumeLabel: UILabel!
    
    @IBOutlet private var drinkButtonsContainer: UIStackView!
    private let drink100mlButton = AddWaterView(title: "+100ml".localized, image: UIImage(imageLiteralResourceName: "glass100ml"))
    private let drink200mlButton = AddWaterView(title: "+200ml".localized, image: UIImage(imageLiteralResourceName: "glass200ml"))
    private let drink300mlButton = AddWaterView(title: "+300ml".localized, image: UIImage(imageLiteralResourceName: "glass300ml"))
    
    @IBOutlet private var waterControlConfigurationButton: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        extensionContext?.widgetLargestAvailableDisplayMode = .compact
        
        drinkButtonsContainer.addArrangedSubview(drink100mlButton)
        drinkButtonsContainer.addArrangedSubview(drink200mlButton)
        drinkButtonsContainer.addArrangedSubview(drink300mlButton)
        drink100mlButton.addTarget(self, action: #selector(onTapToDrinkButton(_:)), for: .touchUpInside)
        drink200mlButton.addTarget(self, action: #selector(onTapToDrinkButton(_:)), for: .touchUpInside)
        drink300mlButton.addTarget(self, action: #selector(onTapToDrinkButton(_:)), for: .touchUpInside)
        
        setupWaterControlConfigurationButton()
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        guard let sprint = getCurrentSprint() else {
            completionHandler(NCUpdateResult.noData)
            return
        }
        
        waterControlLoader.loadWaterControl(sprintID: sprint.id) { state in
            switch state {
            case .notConfigured:
                waterLevelView.isHidden = true
                waterControlConfigurationButton.isHidden = false
                setDrinkWaterButtonsVisible(false)
                drunkVolumeLabel.isHidden = true
            case let .configured(waterControl):
                self.waterControl = waterControl
                waterLevelView.isHidden = false
                waterControlConfigurationButton.isHidden = true
                setDrinkWaterButtonsVisible(true)
                drunkVolumeLabel.isHidden = false
            }
        }
        
        completionHandler(NCUpdateResult.newData)
    }
    
    @IBAction private func onTapToDrinkButton(_ button: UIControl) {
        switch button {
        case drink100mlButton: addDrunkVolume(milliliters: 100)
        case drink200mlButton: addDrunkVolume(milliliters: 200)
        case drink300mlButton: addDrunkVolume(milliliters: 300)
        default: return
        }
    }
    
    @IBAction private func onTapToSetupWaterControlButton() {
        guard let appURL = URL(string: "agilee://configure_water_control") else { return }
        extensionContext?.open(appURL, completionHandler: nil)
    }
    
    private func updateWaterControlUI() {
        guard let waterControl = waterControl else { return }
        let todayDrunkVolume = waterControl.drunkVolume[Date().startOfDay] ?? 0
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
    
    private func addDrunkVolume(milliliters: Int) {
        guard let waterControl = waterControl else { return }
        let todayDrunkVolume = waterControl.drunkVolume[Date.now.startOfDay] ?? 0
        waterControl.drunkVolume[Date.now.startOfDay] = todayDrunkVolume + milliliters
        waterControlService.createOrUpdateWaterControl(waterControl) { [weak self] in
            self?.updateWaterControlUI()
        }
    }
    
    private func setDrinkWaterButtonsVisible(_ isVisible: Bool) {
        drinkButtonsContainer.isHidden = !isVisible
    }
    
    func setupWaterControlConfigurationButton() {
        waterControlConfigurationButton.setTitle("configure_water_control".localized, for: .normal)
        waterControlConfigurationButton.setBackgroundImage(UIImage.plain(color: UIColor(rgba: "29C3FE")), for: .normal)
        waterControlConfigurationButton.setTitleColor(.white, for: .normal)
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

final class WaterControlLoader {
    
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
        
        setupAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupConstraints()
    }
    
    func setupAppearance() {
        volumeLabel.textColor = .black
        volumeLabel.font = UIFont.systemFont(ofSize: 12)
    }
    
    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        
        [imageView.leading(), imageView.trailing(), imageView.top()].toSuperview()
        [volumeLabel.leading(), volumeLabel.trailing(), volumeLabel.bottom()].toSuperview()
        
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1).isActive = true
        imageView.bottomToTop(-2).to(volumeLabel, addTo: self)
    }
    
}

final class WaterLevelView: UIView {
    
    var waterLevel: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var waterColor: UIColor = .blue
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.height / 2
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard waterLevel > 0 else { return }
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setFillColor(waterColor.cgColor)
        
        let waterRect = CGRect(x: 0, y: rect.height - waterLevel * rect.height, width: rect.width, height: waterLevel * rect.height)
        
        context.fill(waterRect)
    }
    
}
