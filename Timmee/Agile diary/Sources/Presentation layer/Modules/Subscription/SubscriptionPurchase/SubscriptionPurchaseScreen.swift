//
//  SubscriptionPurchaseScreen.swift
//  Agile diary
//
//  Created by Илья Харабет on 11.05.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit

final class SubscriptionPurchaseScreen: BaseViewController, AlertInput {
    
    private let loadingBackgroundView = UIView()
    private let loadingView = LoadingView()
    
    private let placeholderView = ScreenPlaceholderView()
    
    private let descriptionLabel = UILabel()
    private let subscriptionsContainer = UIStackView()
    private let buyButton = ContinueEducationButton()
    private let restoreButton = ContinueEducationButton()
    
    private var selectedSubscription = SwiftyStoreKit.Subscription.annual
    
    override func prepare() {
        super.prepare()
        
        setupViews()
        
        loadSubscriptions()
    }
    
    override func setupAppearance() {
        super.setupAppearance()
                
        buyButton.setTitleColor(.white, for: .normal)
        restoreButton.setTitleColor(AppTheme.current.colors.inactiveElementColor, for: .normal)
        
        buyButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        restoreButton.backgroundColor = .clear
    }
    
    @objc private func didTapBuyButton() {
        SwiftyStoreKit.purchase(subscription: selectedSubscription) { result in
            switch result {
            case .success:
                self.dismiss(animated: true, completion: nil)
            case let .error(error):
                self.showAlert(
                    title: "error".localized,
                    message: error.localizedDescription,
                    actions: [.ok("close".localized)],
                    completion: nil
                )
            }
        }
    }
    
    @objc private func didTapRestoreButton() {
        SwiftyStoreKit.restoreSubscription { success in
            if success {
                self.dismiss(animated: true, completion: nil)
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
        navigationItem.title = "subscription_purchase_screen_title".localized
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(loadingBackgroundView)
        loadingBackgroundView.backgroundColor = AppTheme.current.colors.middlegroundColor
        loadingBackgroundView.allEdges().toSuperview()
        
        loadingBackgroundView.addSubview(loadingView)
        loadingView.width(40)
        loadingView.height(40)
        [loadingView.centerX(), loadingView.centerY()].toSuperview()
        
        placeholderView.setup(into: view)
        placeholderView.backgroundColor = AppTheme.current.colors.middlegroundColor
        placeholderView.setVisible(false, animated: false)
        
        view.addSubview(descriptionLabel)
        descriptionLabel.text = "subscription_purchase_description".localized
        descriptionLabel.font = AppTheme.current.fonts.regular(17)
        descriptionLabel.textColor = AppTheme.current.colors.activeElementColor
        descriptionLabel.numberOfLines = 0
        descriptionLabel.top(15).to(view.safeAreaLayoutGuide)
        [descriptionLabel.leading(15), descriptionLabel.trailing(15)].toSuperview()
        
        view.addSubview(subscriptionsContainer)
        subscriptionsContainer.axis = .vertical
        subscriptionsContainer.spacing = 8
        subscriptionsContainer.topToBottom(30).to(descriptionLabel, addTo: view)
        [subscriptionsContainer.leading(15), subscriptionsContainer.trailing(15)].toSuperview()
        
        let buttonsContainer = UIStackView(arrangedSubviews: [buyButton, restoreButton])
        buttonsContainer.axis = .vertical
        buttonsContainer.spacing = 8
        view.addSubview(buttonsContainer)
        [buttonsContainer.leading(15), buttonsContainer.trailing(15)].toSuperview()
        buttonsContainer.bottom(8).to(view.safeAreaLayoutGuide)
        
        buyButton.height(48)
        buyButton.setTitle("buy_subscription".localized, for: .normal)
        buyButton.titleLabel?.font = AppTheme.current.fonts.regular(15)
        buyButton.addTarget(self, action: #selector(didTapBuyButton), for: .touchUpInside)
        
        restoreButton.height(48)
        restoreButton.setTitle("restore_subscription".localized, for: .normal)
        restoreButton.titleLabel?.font = AppTheme.current.fonts.regular(15)
        restoreButton.addTarget(self, action: #selector(didTapRestoreButton), for: .touchUpInside)
    }
    
    private func loadSubscriptions() {
        setLoading(true)
        placeholderView.setVisible(false, animated: false)
        
        SwiftyStoreKit.retrieveSubscriptions { result in
            switch result {
            case let .success(products):
                self.setLoading(false)
                self.updateSubscriptions(products: products)
            case let .failure(error):
                self.setLoading(false)
                self.showErrorPlaceholder(message: error.localizedDescription)
            }
        }
    }
    
    private func updateSubscriptions(products: [SKProduct]) {
        subscriptionsContainer.arrangedSubviews.forEach {
            subscriptionsContainer.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        products.forEach { product in
            let view = SubscriptionView()
            view.configure(
                title: product.localizedTitle,
                subtitle: product.localizedDescription,
                price: product.localizedPrice ?? ""
            )
            view.setSelected(selectedSubscription.rawValue == product.productIdentifier)
            view.onTap = { [unowned self] in
                self.selectedSubscription = SwiftyStoreKit.Subscription.allCases.first(where: { $0.rawValue == product.productIdentifier }) ?? .monthly
                self.updateSubscriptions(products: products)
            }
            subscriptionsContainer.addArrangedSubview(view)
        }
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
            self.loadSubscriptions()
        }
        placeholderView.setVisible(true, animated: false)
    }
    
}

private final class SubscriptionView: UIView {
    
    var onTap: (() -> Void)?
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let priceLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let sideOffset = CGFloat(12)
        
        layer.cornerRadius = 12
        
        titleLabel.font = AppTheme.current.fonts.medium(20)
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        titleLabel.numberOfLines = 0
        
        subtitleLabel.font = AppTheme.current.fonts.regular(14)
        subtitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        subtitleLabel.numberOfLines = 0
        
        let titlesContainer = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titlesContainer.axis = .vertical
        titlesContainer.spacing = 4
        addSubview(titlesContainer)
        [titlesContainer.top(sideOffset), titlesContainer.bottom(sideOffset), titlesContainer.leading(sideOffset)].toSuperview()
        
        priceLabel.font = AppTheme.current.fonts.bold(16)
        priceLabel.textColor = AppTheme.current.colors.mainElementColor
        priceLabel.textAlignment = .right
        priceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        addSubview(priceLabel)
        priceLabel.leadingToTrailing(8).to(titlesContainer, addTo: self)
        [priceLabel.centerY(), priceLabel.trailing(sideOffset)].toSuperview()
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(title: String, subtitle: String, price: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        priceLabel.text = price
    }
    
    func setSelected(_ isSelected: Bool) {
        backgroundColor = isSelected ? AppTheme.current.colors.foregroundColor : AppTheme.current.colors.middlegroundColor
    }
    
    @objc private func didTap() {
        onTap?()
    }
    
}
