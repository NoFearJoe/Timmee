//
//  GoalStepsViewController.swift
//  Agile diary
//
//  Created by Илья Харабет on 01/12/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

protocol GoalStepsOutput: AnyObject {
    func didAskToContinue(steps: [GoalStep])
}

final class GoalStepsViewController: BaseViewController {
    
    weak var output: GoalStepsOutput?
        
    private let titleLabel = UILabel()
    private let hintLabel = UILabel()
    private let continueButton = UIButton()
    
    private var shouldFocusInputField = true
    
    override func prepare() {
        super.prepare()
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
        
        setupViews()
        setupLayout()
        addBackgroundTapGestureRecognizer()
    }
    
    override func refresh() {
        super.refresh()
        
        titleLabel.text = "goal_steps_screen_title".localized
        hintLabel.text = "goal_steps_hint".localized
        continueButton.setTitle("continue".localized, for: .normal)
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        
        titleLabel.font = AppTheme.current.fonts.bold(32)
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        
        hintLabel.font = AppTheme.current.fonts.regular(15)
        hintLabel.textColor = AppTheme.current.colors.inactiveElementColor
        
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        continueButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.inactiveElementColor), for: .disabled)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard shouldFocusInputField else { return }
        shouldFocusInputField = false
        
    }
    
}

private extension GoalStepsViewController {
    
    func setupViews() {
        titleLabel.numberOfLines = 0
        view.addSubview(titleLabel)
        
        hintLabel.numberOfLines = 0
        view.addSubview(hintLabel)
        
        continueButton.layer.cornerRadius = 8
        continueButton.clipsToBounds = true
        continueButton.isEnabled = false
        continueButton.addTarget(self, action: #selector(onTapContinueButton), for: .touchUpInside)
        view.addSubview(continueButton)
    }
    
    func setupLayout() {
        if #available(iOS 11.0, *) {
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44).isActive = true
        } else {
            titleLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 44).isActive = true
        }
        [titleLabel.leading(16), titleLabel.trailing(16)].toSuperview()
                
        hintLabel.topToBottom(20).to(titleLabel, addTo: view)
        [hintLabel.leading(16), hintLabel.trailing(16)].toSuperview()
        
        [continueButton.leading(16), continueButton.trailing(16)].toSuperview()
        continueButton.height(52)
        if #available(iOS 11.0, *) {
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        } else {
            continueButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20).isActive = true
        }
    }
    
}

private extension GoalStepsViewController {
    
    @objc func onTapContinueButton() {
        output?.didAskToContinue(steps: [])
    }
    
}

private extension GoalStepsViewController {
    
    func addBackgroundTapGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapBackground))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func onTapBackground() {
        view.endEditing(true)
    }
    
}
