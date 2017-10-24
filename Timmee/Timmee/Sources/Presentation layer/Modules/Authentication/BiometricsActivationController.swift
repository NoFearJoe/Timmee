//
//  BiometricsActivationController.swift
//  Timmee
//
//  Created by Ilya Kharabet on 14.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIImage
import class UIKit.UILabel
import class UIKit.UIButton
import class UIKit.UIImageView
import class UIKit.UIViewController
import class LocalAuthentication.LAContext

enum BiometricsType {
    case none
    case touchID
    case faceID
    
    var localizedTitle: String {
        switch self {
        case .none: return "error".localized
        case .touchID: return "enter_with_touch_id".localized
        case .faceID: return "enter_with_face_id".localized
        }
    }
    
    var localizedSubtitle: String {
        switch self {
        case .none: return "device_is_not_support_biometrics".localized
        case .touchID: return "enter_with_touch_id_question".localized
        case .faceID: return "enter_with_fase_id_question".localized
        }
    }
    
    var localizedReason: String {
        switch self {
        case .none: return ""
        case .touchID: return "touch_id_reason".localized
        case .faceID: return "face_id_reason".localized
        }
    }
    
    var image: UIImage {
        switch self {
        case .none: return UIImage()
        case .touchID: return #imageLiteral(resourceName: "touchIDBig")
        case .faceID: return #imageLiteral(resourceName: "faceIDBig")
        }
    }
}

final class BiometricsActivationController: UIViewController {
    
    @IBOutlet fileprivate var imageView: UIImageView!
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var subtitleLabel: UILabel!
    
    @IBOutlet fileprivate var acceptButton: UIButton!
    @IBOutlet fileprivate var declineButton: UIButton!
    
    fileprivate lazy var biometricsType: BiometricsType = {
        let localAuthenticationContext = LAContext()
        guard localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            else { return .none }
        
        if #available(iOS 11.0, *) {
            switch localAuthenticationContext.biometryType {
            case .typeFaceID: return .faceID
            case .typeTouchID: return .touchID
            case .none: return .none
            }
        } else {
            return .touchID
        }
    }()
    
    var onComplete: (() -> Void)?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        applyAppearance()
        
        imageView.image = biometricsType.image
        titleLabel.text = biometricsType.localizedTitle
        subtitleLabel.text = biometricsType.localizedSubtitle
        
        acceptButton.isHidden = biometricsType == .none
        acceptButton.setTitle("activate".localized, for: .normal)
        if biometricsType == .none {
            declineButton.setTitle("close".localized, for: .normal)
        } else {
            declineButton.setTitle("no_thanks".localized, for: .normal)
        }
    }
    
    @IBAction func accept() {
        UserProperty.biometricsAuthenticationEnabled.setBool(true)
        onComplete?()
    }
    
    @IBAction func decline() {
        UserProperty.biometricsAuthenticationEnabled.setBool(false)
        onComplete?()
    }
    
}

fileprivate extension BiometricsActivationController {
    
    func applyAppearance() {
        titleLabel.textColor = AppTheme.current.scheme.tintColor
        subtitleLabel.textColor = AppTheme.current.scheme.secondaryTintColor
        
        acceptButton.setTitleColor(AppTheme.current.scheme.tintColor, for: .normal)
        declineButton.setTitleColor(AppTheme.current.scheme.tintColor, for: .normal)
        
        acceptButton.backgroundColor = AppTheme.current.scheme.blueColor
        declineButton.backgroundColor = AppTheme.current.scheme.panelColor
        
        acceptButton.layer.cornerRadius = 6
        declineButton.layer.cornerRadius = 6
    }
    
}
