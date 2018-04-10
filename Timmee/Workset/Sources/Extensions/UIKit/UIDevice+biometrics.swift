//
//  UIDevice+biometrics.swift
//  Timmee
//
//  Created by Ilya Kharabet on 06.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIImage
import class UIKit.UIDevice
import class LocalAuthentication.LAContext

public extension UIDevice {
    
    public var biometricsType: BiometricsType {
        let localAuthenticationContext = LAContext()
        guard localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
            else { return .none }
        
        if #available(iOS 11.0, *) {
            switch localAuthenticationContext.biometryType {
            case .faceID: return .faceID
            case .touchID: return .touchID
            case .none: return .none
            }
        } else {
            return .touchID
        }
    }
    
}

public enum BiometricsType {
    case none
    case touchID
    case faceID
    
    public var localizedTitle: String {
        switch self {
        case .none: return "error".localized
        case .touchID: return "touch_id".localized
        case .faceID: return "face_id".localized
        }
    }
    
    public var localizedSubtitle: String {
        switch self {
        case .none: return "device_is_not_support_biometrics".localized
        case .touchID: return "enter_with_touch_id_question".localized
        case .faceID: return "enter_with_fase_id_question".localized
        }
    }
    
    public var localizedReason: String {
        switch self {
        case .none: return ""
        case .touchID: return "touch_id_reason".localized
        case .faceID: return "face_id_reason".localized
        }
    }
    
    public var image: UIImage {
        switch self {
        case .none: return UIImage()
        case .touchID: return #imageLiteral(resourceName: "touchIDBig")
        case .faceID: return #imageLiteral(resourceName: "faceIDBig")
        }
    }
    
    public var smallImage: UIImage {
        switch self {
        case .none: return UIImage()
        case .touchID: return #imageLiteral(resourceName: "touchIDSmall")
        case .faceID: return #imageLiteral(resourceName: "faceIDSmall")
        }
    }
    
    public var settingsImage: UIImage {
        switch self {
        case .none: return UIImage()
        case .touchID: return #imageLiteral(resourceName: "touchIDSettings")
        case .faceID: return #imageLiteral(resourceName: "faceIDSettings")
        }
    }
}
