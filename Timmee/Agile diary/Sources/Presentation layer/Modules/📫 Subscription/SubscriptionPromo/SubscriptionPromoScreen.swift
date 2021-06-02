//
//  SubscriptionPromoScreen.swift
//  Agile diary
//
//  Created by Илья Харабет on 11.05.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit
import SwiftyStoreKit

final class SubscriptionPromoScreen: BaseViewController, AlertInput {
    
    private let loadingBackgroundView = UIView()
    private let loadingView = LoadingView()
    
    private let placeholderView = ScreenPlaceholderView()
    
    private let headerView = DefaultLargeHeaderView()
    private let messageLabel = UILabel()
    private let continueButton = ContinueEducationButton()
    private let restorePurchasesButton = ContinueEducationButton()
    
    private unowned let output: EducationScreenOutput
    
    init(output: EducationScreenOutput) {
        self.output = output
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func prepare() {
        super.prepare()
        
        setupViews()
        
        loadSubscriptionInfo()
    }
    
    override func setupAppearance() {
        super.setupAppearance()
                
        continueButton.setTitleColor(.white, for: .normal)
        restorePurchasesButton.setTitleColor(AppTheme.current.colors.inactiveElementColor, for: .normal)
        
        continueButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        restorePurchasesButton.backgroundColor = .clear
    }
    
    @objc private func didTapContinueButton() {
        output.didAskToContinueEducation(screen: .subscriptionPromo)
    }
    
    @objc private func didTapRestorePurchasesButton() {
        SwiftyStoreKit.restoreSubscription { success in
            if success {
                self.output.didAskToContinueEducation(screen: .subscriptionPromo)
            } else {
                self.showAlert(
                    title: "error".localized,
                    message: "restore_error_try_again".localized,
                    actions: [.ok("close".localized)],
                    completion: nil
                )
            }
        }
    }
    
    private func setupViews() {
        view.addSubview(loadingBackgroundView)
        loadingBackgroundView.backgroundColor = AppTheme.current.colors.middlegroundColor
        loadingBackgroundView.allEdges().toSuperview()
        
        loadingBackgroundView.addSubview(loadingView)
        loadingView.width(40)
        loadingView.height(40)
        [loadingView.centerX(), loadingView.centerY()].toSuperview()
        
        placeholderView.setup(into: view)
        placeholderView.backgroundColor = AppTheme.current.colors.middlegroundColor
        
        view.addSubview(headerView)
        [headerView.leading(), headerView.trailing(), headerView.top()].toSuperview()
        headerView.backgroundColor = .clear
        headerView.drawBottomLine = false
        headerView.configure(
            title: "subscription_promo_screen_title".localized,
            subtitle: nil,
            onTapLeftButton: nil,
            onTapRightButton: nil
        )
        
        view.addSubview(messageLabel)
        messageLabel.font = AppTheme.current.fonts.regular(17)
        messageLabel.textColor = AppTheme.current.colors.activeElementColor
        messageLabel.numberOfLines = 0
        messageLabel.text = "subscription_promo_screen_message".localized
        messageLabel.topToBottom(15).to(headerView, addTo: view)
        [messageLabel.leading(15), messageLabel.trailing(15)].toSuperview()
        
        let buttonsContainer = UIStackView(arrangedSubviews: [continueButton, restorePurchasesButton])
        buttonsContainer.axis = .vertical
        buttonsContainer.spacing = 8
        view.addSubview(buttonsContainer)
        [buttonsContainer.leading(15), buttonsContainer.trailing(15)].toSuperview()
        buttonsContainer.bottom(8).to(view.safeAreaLayoutGuide)
        
        continueButton.height(48)
        continueButton.titleLabel?.font = AppTheme.current.fonts.regular(15)
        continueButton.setTitle("continue".localized, for: .normal)
        continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)
        
        restorePurchasesButton.height(48)
        restorePurchasesButton.titleLabel?.font = AppTheme.current.fonts.regular(15)
        restorePurchasesButton.setTitle("restore_purchases".localized, for: .normal)
        restorePurchasesButton.addTarget(self, action: #selector(didTapRestorePurchasesButton), for: .touchUpInside)
    }
    
    private func setLoading(_ isLoading: Bool) {
        loadingBackgroundView.isHidden = !isLoading
        loadingView.isHidden = !isLoading
        
        if isLoading {
            view.bringSubviewToFront(loadingBackgroundView)
        }
    }
    
    private func showErrorPlaceholder(message: String) {
        placeholderView.configure(title: "error".localized, message: message, action: "retry".localized) { [unowned self] in
            self.loadSubscriptionInfo()
        }
        placeholderView.setVisible(true, animated: false)
    }

    private func showSubscriptionExpiredPlaceholder() {
        placeholderView.configure(
            title: "subscription_expired".localized,
            message: "subscription_expired_message".localized,
            action: "prolongate_subscription".localized
        ) { [unowned self] in
            let s = SubscriptionPurchaseScreen(onFinish: {
                self.output.didAskToContinueEducation(screen: .subscriptionPromo)
            })
            let vc = UINavigationController(rootViewController: s)
            vc.modalPresentationStyle = .fullScreen
            self.present(
                vc,
                animated: true,
                completion: nil
            )
        }
        placeholderView.setVisible(true, animated: false)
    }
    
    private func loadSubscriptionInfo() {
        setLoading(true)
        SwiftyStoreKit.verifySubscriptions { result in
            switch result {
            case let .success(result):
                switch result {
                case .purchased:
                    self.output.didAskToSkipEducation(screen: .subscriptionPromo)
                case .expired:
                    self.setLoading(false)
                    self.showSubscriptionExpiredPlaceholder()
                case .notPurchased:
                    self.setLoading(false)
                }
            case let .failure(error):
                self.setLoading(false)
                self.showErrorPlaceholder(message: error.localizedDescription)
            }
        }
    }
    
}
