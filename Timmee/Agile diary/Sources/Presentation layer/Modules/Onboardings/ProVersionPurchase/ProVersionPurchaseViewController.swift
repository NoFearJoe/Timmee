//
//  ProVersionPurchaseViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 28/03/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class ProVersionPurchaseViewController: BaseViewController, AlertInput {
    
    @IBOutlet private var headerView: LargeHeaderView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var featuresStackView: UIStackView!
    
    @IBOutlet private var buyProVersionButton: ContinueEducationButton!
    @IBOutlet private var restoreProVersionButton: ContinueEducationButton!
    
    @IBOutlet private var loadingView: LoadingView!
    
    @IBAction private func onBuyProVersionButtonTap() {
        loadingView.isHidden = false
        ProVersionPurchase.shared.requestData { [weak self] in
            ProVersionPurchase.shared.purchase { [weak self] in
                self?.loadingView.isHidden = true
                if ProVersionPurchase.shared.isPurchased() {
                    self?.dismiss(animated: true, completion: nil)
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
                    self?.dismiss(animated: true, completion: nil)
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
    
    @IBAction private func onCloseButtonTap() {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare() {
        super.prepare()
        
        headerView.titleLabel.text = "pro_version".localized
        
        titleLabel.text = "pro_version_description".localized
        
        buyProVersionButton.setTitle("buy_for".localized + " " + "pro_version_price".localized, for: .normal)
        restoreProVersionButton.setTitle("restore".localized, for: .normal)
        
        addFeaturesInStackView()
    }
    
    override func refresh() {
        super.refresh()
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        titleLabel.font = AppTheme.current.fonts.medium(16)
        titleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        buyProVersionButton.setTitleColor(.white, for: .normal)
        restoreProVersionButton.setTitleColor(.white, for: .normal)        
        buyProVersionButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        restoreProVersionButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.inactiveElementColor), for: .normal)
    }
    
    private func addFeaturesInStackView() {
        featuresStackView.spacing = UIScreen.main.isLittle ? 4 : 8
        featuresStackView.arrangedSubviews.forEach {
            featuresStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        for i in 0...2 {
            let featureIcon = UIImage(named: "pro_version_feature_icon_\(i)")
            let featureTitle = "pro_version_feature_\(i)".localized
            let view = ProVersionFeatureView.loadedFromNib()
            view.configure(icon: featureIcon ?? UIImage(), title: featureTitle)
            if UIScreen.main.isLittle {
                view.height(40)
            } else {
                view.height(44)
            }
            featuresStackView.addArrangedSubview(view)
        }
    }
    
}
