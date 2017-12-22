//
//  InAppPurchaseViewController.swift
//  Timmee
//
//  Created by Ilya Kharabet on 06.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class InAppPurchaseViewController: UIViewController {
    
    @IBOutlet fileprivate var inAppImageView: UIImageView!
    @IBOutlet fileprivate var inAppTitleLabel: UILabel!
    @IBOutlet fileprivate var inAppDescriptionLabel: UILabel!
    @IBOutlet fileprivate var inAppPurchaseButton: UIButton!
    @IBOutlet fileprivate var activityIndicator: UIActivityIndicatorView!
    
    @IBAction fileprivate func purchase() {
        guard let purchase = inAppPurchase else { return }
        guard purchase.canPurchase() else { return }
        
        setLoadingVisible(true)
        purchase.purchase { [weak self] in
            if let inAppPurchase = self?.inAppPurchase {
                self?.onPurchaseComplete?(inAppPurchase)
            }
            self?.setLoadingVisible(false)
        }
    }
    
    var index: Int = 0
    
    var onPurchaseComplete: ((InAppPurchase) -> Void)?
    
    fileprivate var inAppPurchase: InAppPurchase?
    
    func setInAppItem(_ item: InAppPurchaseItem) {
        view.backgroundColor = item.backgroundColor
        inAppImageView.image = item.icon
        
        inAppTitleLabel.text = item.title
        inAppTitleLabel.textColor = item.tintColor
        
        inAppDescriptionLabel.text = item.description
        inAppDescriptionLabel.textColor = item.tintColor.withAlphaComponent(0.75)
        
        inAppPurchaseButton.layer.borderColor = item.tintColor.cgColor
        inAppPurchaseButton.setTitleColor(item.tintColor, for: .normal)
        
        activityIndicator.color = item.tintColor
        
        inAppPurchase = allInAppPurchases[item.id]
        
        if let purchase = inAppPurchase, purchase.product == nil, !purchase.isLoading {
            setLoadingVisible(true)
            purchase.requestData { [weak self] in
                self?.setLoadingVisible(false)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = AppTheme.current.foregroundColor
        
        inAppPurchaseButton.layer.cornerRadius = 4
        inAppPurchaseButton.layer.borderWidth = 1
    }
    
    fileprivate func setLoadingVisible(_ isVisible: Bool) {
        inAppPurchaseButton.isHidden = isVisible
        activityIndicator.isHidden = !isVisible
        activityIndicator.startAnimating()
    }
    
}
