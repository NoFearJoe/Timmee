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
import class UIKit.UIViewController

final class BiometricsActivationController: UIViewController {
    
    @IBOutlet fileprivate var imageView: UIImageView!
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var subtitleLabel: UILabel!
    
    @IBOutlet fileprivate var acceptButton: UIButton!
    @IBOutlet fileprivate var declineButton: UIButton!
    
    var onComplete: (() -> Void)?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        applyAppearance()
        
        let biometricsType = UIDevice.current.biometricsType
        
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
        view.backgroundColor = AppTheme.current.middlegroundColor
        
        titleLabel.textColor = AppTheme.current.tintColor
        subtitleLabel.textColor = AppTheme.current.secondaryTintColor
        
        acceptButton.setTitleColor(AppTheme.current.tintColor, for: .normal)
        declineButton.setTitleColor(AppTheme.current.tintColor, for: .normal)
        
        acceptButton.backgroundColor = AppTheme.current.blueColor
        declineButton.backgroundColor = AppTheme.current.panelColor
        
        acceptButton.layer.cornerRadius = 6
        declineButton.layer.cornerRadius = 6
    }
    
}
