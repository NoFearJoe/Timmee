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

final class BiometricsActivationController: BaseViewController {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    
    @IBOutlet private var acceptButton: UIButton!
    @IBOutlet private var declineButton: UIButton!
    
    var onComplete: (() -> Void)?
    
    override func refresh() {
        super.refresh()
        
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
    
    override func setupAppearance() {
        super.setupAppearance()
        
        navigationController?.navigationBar.barTintColor = AppTheme.current.colors.foregroundColor
        navigationController?.navigationBar.tintColor = AppTheme.current.colors.activeElementColor
        
        view.backgroundColor = AppTheme.current.colors.middlegroundColor
        
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        subtitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        
        acceptButton.setTitleColor(.white, for: .normal)
        declineButton.setTitleColor(AppTheme.current.colors.inactiveElementColor, for: .normal)
        
        acceptButton.backgroundColor = AppTheme.current.colors.mainElementColor
        declineButton.backgroundColor = .clear
        
        acceptButton.layer.cornerRadius = 12
        declineButton.layer.cornerRadius = 12
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
