//
//  GoalCreationOnboardingViewController.swift
//  Agile diary
//
//  Created by Илья Харабет on 22/12/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import UIComponents

final class GoalCreationOnboardingViewController: BaseViewController {
    
    private let closeButton = UIButton()
    
    private let titleLabel = UILabel()
    
    private let contentScrollView = UIScrollView()
    private let contentView = UIView()
    
    private let textLabel = UILabel()
    
    override func prepare() {
        super.prepare()
        
        setupViews()
        setupStaticContent()
        setupLayout()
    }
    
    override func refresh() {
        super.refresh()
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        
        titleLabel.font = AppTheme.current.fonts.bold(32)
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        
        textLabel.font = AppTheme.current.fonts.regular(15)
        textLabel.textColor = AppTheme.current.colors.activeElementColor
        
        closeButton.tintColor = AppTheme.current.colors.inactiveElementColor
    }
    
    @objc func onTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
}

private extension GoalCreationOnboardingViewController {
    
    func setupViews() {
        closeButton.addTarget(self, action: #selector(onTapCloseButton), for: .touchUpInside)
        view.addSubview(closeButton)
        
        titleLabel.numberOfLines = 0
        view.addSubview(titleLabel)
        
        contentScrollView.contentInset.top = 20
        contentScrollView.showsVerticalScrollIndicator = false
        view.addSubview(contentScrollView)
        
        contentScrollView.addSubview(contentView)
        
        textLabel.numberOfLines = 0
        contentView.addSubview(textLabel)
    }
    
    func setupStaticContent() {
        titleLabel.text = "goal_creation_onboarding_title".localized
        textLabel.text = "goal_creation_onboarding_text".localized
        closeButton.setImage(UIImage(named: "cross"), for: .normal)
    }
    
    func setupLayout() {
        closeButton.trailing(-10).to(view.readableContentGuide)
        closeButton.height(40)
        closeButton.width(40)
        closeButton.top(8).to(view.readableContentGuide)
        
        titleLabel.top(44).to(view.readableContentGuide)
        [titleLabel.leading(), titleLabel.trailing()].to(view.readableContentGuide)
        
        contentScrollView.topToBottom().to(titleLabel, addTo: view)
        [contentScrollView.leading(), contentScrollView.trailing()].to(view.readableContentGuide)
        contentScrollView.bottom().toSuperview()
        
        contentView.allEdges().toSuperview()
        contentView.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor, multiplier: 1).isActive = true
        let contentViewHeightConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        contentViewHeightConstraint.priority = .defaultLow
        contentViewHeightConstraint.isActive = true
        
        textLabel.allEdges().toSuperview()
    }
    
}
