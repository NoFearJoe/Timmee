//
//  BiometricsActivationController.swift
//  Timmee
//
//  Created by Ilya Kharabet on 14.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIDevice
import class UIKit.UIImage
import class UIKit.UILabel
import class UIKit.UIButton
import class UIKit.UIImageView
import enum UIKit.UIStatusBarStyle
import class UIKit.UIViewController

final class BiometricsActivationController: UIViewController {
    
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var subtitleLabel: UILabel!
    
    @IBOutlet fileprivate var acceptButton: UIButton!
    @IBOutlet fileprivate var declineButton: UIButton!
    
    var onComplete: (() -> Void)?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        applyAppearance()
        
        let biometricsType = UIDevice.current.biometricsType
        
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
        navigationController?.navigationBar.barTintColor = AppTheme.current.backgroundColor
        navigationController?.navigationBar.tintColor = AppTheme.current.backgroundTintColor
        
        view.backgroundColor = AppTheme.current.backgroundColor
        
        titleLabel.textColor = AppTheme.current.backgroundTintColor
        subtitleLabel.textColor = AppTheme.current.secondaryBackgroundTintColor
        
        acceptButton.setTitleColor(AppTheme.current.backgroundTintColor, for: .normal)
        declineButton.setTitleColor(AppTheme.current.backgroundTintColor, for: .normal)
        
        acceptButton.backgroundColor = AppTheme.current.blueColor
        declineButton.backgroundColor = AppTheme.current.secondaryBackgroundTintColor
        
        acceptButton.layer.cornerRadius = 6
        declineButton.layer.cornerRadius = 6
    }
    
}
