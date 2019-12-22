//
//  HabitCreationOnboardingViewController.swift
//  Agile diary
//
//  Created by Илья Харабет on 22/12/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import UIComponents

final class HabitCreationOnboardingViewController: BaseViewController {
        
    private let titleLabel = UILabel()
    private let textLabel = UILabel()
    private let closeButton = UIButton()
    
    override func prepare() {
        super.prepare()
        
        setupViews()
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
        textLabel.textColor = AppTheme.current.colors.inactiveElementColor
        
        closeButton.tintColor = AppTheme.current.colors.mainElementColor
        closeButton.setTitleColor(AppTheme.current.colors.mainElementColor, for: .normal)
        closeButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        closeButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.inactiveElementColor), for: .disabled)
    }
    
    @objc func onTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
}

private extension HabitCreationOnboardingViewController {
    
    func setupViews() {
        titleLabel.numberOfLines = 0
        view.addSubview(titleLabel)
        
        textLabel.numberOfLines = 0
        view.addSubview(textLabel)
        
        closeButton.layer.cornerRadius = 8
        closeButton.clipsToBounds = true
        closeButton.isEnabled = false
        closeButton.addTarget(self, action: #selector(onTapCloseButton), for: .touchUpInside)
        view.addSubview(closeButton)
    }
    
    func setupStaticContent() {
        titleLabel.text = "habit_creation_onboarding_title".localized
        textLabel.text = "habit_creation_onboarding_text".localized
        closeButton.setImage(UIImage(named: "cross"), for: .normal)
    }
    
    func setupLayout() {
        titleLabel.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor, constant: 44).isActive = true
        [titleLabel.leading(16), titleLabel.trailing(16)].toSuperview()
        
        textLabel.topToBottom(20).to(titleLabel, addTo: view)
        [textLabel.leading(16), textLabel.trailing(16)].toSuperview()
        
        closeButton.trailing(8).toSuperview()
        closeButton.height(40)
        closeButton.width(40)
        closeButton.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor, constant: 8).isActive = true
    }
    
}
