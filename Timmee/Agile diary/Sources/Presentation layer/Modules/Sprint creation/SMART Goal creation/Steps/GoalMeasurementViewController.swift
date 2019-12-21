//
//  GoalMeasurementViewController.swift
//  Agile diary
//
//  Created by Илья Харабет on 01/12/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

protocol GoalMeasurementOutput: AnyObject {
    func didAskToContinue(measurement: String)
}

final class GoalMeasurementViewController: BaseViewController {
    
    weak var output: GoalMeasurementOutput?
    
    private let titleLabel = UILabel()
    private let inputField = GrowingTextView()
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
        
        titleLabel.text = "goal_measurement_screen_title".localized
        inputField.placeholderAttributedText
            = NSAttributedString(string: "goal_measurement_input_placeholder".localized,
                                 attributes: [.font: AppTheme.current.fonts.medium(20),
                                              .foregroundColor: AppTheme.current.colors.inactiveElementColor])
        hintLabel.text = "goal_measurement_hint".localized
        continueButton.setTitle("continue".localized, for: .normal)
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        
        titleLabel.font = AppTheme.current.fonts.bold(32)
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        
        inputField.textView.textColor = AppTheme.current.colors.activeElementColor
        inputField.textView.font = AppTheme.current.fonts.medium(20)
        inputField.textView.keyboardAppearance = AppTheme.current.keyboardStyleForTheme
        
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
        
        inputField.becomeFirstResponder()
    }
    
}

private extension GoalMeasurementViewController {
    
    func setupViews() {
        titleLabel.numberOfLines = 0
        view.addSubview(titleLabel)
        
        inputField.textView.delegate = self
        inputField.maxNumberOfLines = 10
        inputField.showsVerticalScrollIndicator = false
        view.addSubview(inputField)
        
        hintLabel.numberOfLines = 0
        view.addSubview(hintLabel)
        
        continueButton.layer.cornerRadius = 8
        continueButton.clipsToBounds = true
        continueButton.isEnabled = false
        continueButton.addTarget(self, action: #selector(onTapContinueButton), for: .touchUpInside)
        view.addSubview(continueButton)
        
        setupInputObserver()
    }
    
    func setupLayout() {
        if #available(iOS 11.0, *) {
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44).isActive = true
        } else {
            titleLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 44).isActive = true
        }
        [titleLabel.leading(16), titleLabel.trailing(16)].toSuperview()
        
        inputField.topToBottom(20).to(titleLabel, addTo: view)
        [inputField.leading(16), inputField.trailing(16)].toSuperview()
        
        hintLabel.topToBottom(20).to(inputField, addTo: view)
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

private extension GoalMeasurementViewController {
    
    @objc func onTapContinueButton() {
        guard let measurement = inputField.textView.text.nilIfEmpty else {
            return
        }
        
        output?.didAskToContinue(measurement: measurement)
    }
    
}

private extension GoalMeasurementViewController {
    
    private func setupInputObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChange),
                                               name: UITextView.textDidChangeNotification,
                                               object: inputField.textView)
    }
    
    @objc func textDidChange(notification: Notification) {
        continueButton.isEnabled = !inputField.textView.text.isEmpty
    }
    
}

extension GoalMeasurementViewController: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.inputField.setContentOffset(.zero, animated: true)
    }
    
}

private extension GoalMeasurementViewController {
    
    func addBackgroundTapGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapBackground))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func onTapBackground() {
        view.endEditing(true)
    }
    
}
