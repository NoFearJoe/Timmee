//
//  ProVersionEducationScreen.swift
//  Agile diary
//
//  Created by i.kharabet on 28.01.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class ProVersionEducationScreen: BaseViewController, AlertInput {
    
    private var output: EducationScreenOutput!
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    
    @IBOutlet private var buyProVersionButton: ContinueEducationButton!
    @IBOutlet private var restoreProVersionButton: ContinueEducationButton!
    @IBOutlet private var skipButton: UIButton!
    
    @IBOutlet private var loadingView: LoadingView!
    
    @IBAction private func onBuyProVersionButtonTap() {
        loadingView.isHidden = false
        ProVersionPurchase.shared.requestData { [weak self] in
            ProVersionPurchase.shared.purchase { [weak self] in
                self?.loadingView.isHidden = true
                if ProVersionPurchase.shared.isPurchased() {
                    self?.showAuthorization()
                    TrackersConfigurator.shared.showProVersionTracker?.disable()
                } else {
                    self?.showAlert(title: "error".localized,
                                    message: "purchase_pro_version_error_try_again".localized,
                                    actions: [.ok("Ok")],
                                    completion: nil)
                }
            }
        }
    }
    
    @IBAction private func onRestoreProVersionButtonTap() {
        loadingView.isHidden = false
        ProVersionPurchase.shared.requestData { [weak self] in
            ProVersionPurchase.shared.restore { [weak self] success in
                self?.loadingView.isHidden = true
                if success, ProVersionPurchase.shared.isPurchased() {
                    self?.showAuthorization()
                    TrackersConfigurator.shared.showProVersionTracker?.disable()
                } else {
                    self?.showAlert(title: "error".localized,
                                    message: "restore_error_try_again".localized,
                                    actions: [.ok("Ok")],
                                    completion: nil)
                }
            }
        }
    }
    
    @IBAction private func onSkipButtonTap() {
        output.didAskToSkipEducation(screen: .proVersion)
    }
    
    override func prepare() {
        super.prepare()
        
        titleLabel.text = "education_pro_version_title".localized
        textLabel.text = "education_pro_version_text".localized
        
        buyProVersionButton.setTitle("education_pro_version_buy".localized, for: .normal)
        restoreProVersionButton.setTitle("education_pro_version_restore".localized, for: .normal)
        skipButton.setTitle("education_pro_version_skip".localized, for: .normal)
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        textLabel.textColor = AppTheme.current.colors.inactiveElementColor
        
        buyProVersionButton.setTitleColor(.white, for: .normal)
        restoreProVersionButton.setTitleColor(.white, for: .normal)
        skipButton.setTitleColor(AppTheme.current.colors.inactiveElementColor, for: .normal)
        
        buyProVersionButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.incompleteElementColor), for: .normal)
        restoreProVersionButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        skipButton.backgroundColor = .clear
    }
    
}

extension ProVersionEducationScreen: EducationScreenInput {
    
    func setupOutput(_ output: EducationScreenOutput) {
        self.output = output
    }
    
}

extension ProVersionEducationScreen: AuthorizationViewControllerDelegate {
    
    func authorizationController(_ viewController: AuthorizationViewController, didCompleteAuthorization successfully: Bool) {
        self.output.didAskToContinueEducation(screen: .proVersion)
    }
    
}

private extension ProVersionEducationScreen {

    func showAuthorization() {
        let authorizationViewController = ViewControllersFactory.authorization
        authorizationViewController.delegate = self
        present(authorizationViewController, animated: true, completion: nil)
    }
    
}
