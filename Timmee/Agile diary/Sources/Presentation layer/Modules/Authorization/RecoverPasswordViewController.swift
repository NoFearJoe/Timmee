//
//  RecoverPasswordViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 16.01.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import Authorization

final class RecoverPasswordViewController: BaseViewController, AlertInput {
    
    private let authorizationService = AuthorizationService()
    
    private var emailFieldValidator: EmailFieldValidator!
    
    private let keyboardManager = KeyboardManager()
    
    @IBOutlet private var headerView: LargeHeaderView!
    
    @IBOutlet private var emailTitleLabel: UILabel!
    @IBOutlet private var emailTextField: FocusableTextField!
    @IBOutlet private var emailSubtitleLabel: UILabel!
    
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var recoverButton: ContinueEducationButton!
    @IBOutlet private var recoverButtonBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private var loadingView: LoadingView!
    
    @IBAction private func onTapToCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func onTapToRecoverButton() {
        guard let email = emailTextField.text?.trimmed.nilIfEmpty else { return }
        loadingView.isHidden = false
        authorizationService.initiatePasswordRecover(email: email) { [weak self] success in
            self?.loadingView.isHidden = true
            if success {
                self?.showSuccessfullRecoverPasswordAlert {
                    self?.dismiss(animated: true, completion: nil)
                }
            } else {
                self?.showRecoverPasswordErrorAlert()
            }
        }
    }
    
    @IBAction private func onTapToBackgroundView() {
        view.endEditing(true)
    }
    
    override func prepare() {
        super.prepare()
        
        headerView.titleLabel.text = "recover_password_title".localized
        emailTitleLabel.text = "e-mail".localized
        emailSubtitleLabel.text = "recover_password_email_hint".localized
        recoverButton.setTitle("recover_password".localized, for: .normal)
        
        recoverButton.isEnabled = false
        
        emailFieldValidator = EmailFieldValidator(emailTextField: emailTextField, onValid: { [unowned self] isValid in
            self.recoverButton.isEnabled = isValid
        })
        
        setupKeyboardManager()
        
        if !emailTextField.isFirstResponder {
            emailTextField.becomeFirstResponder()
        }
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        emailTitleLabel.font = AppTheme.current.fonts.regular(16)
        emailTitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        emailTextField.font = AppTheme.current.fonts.bold(18)
        emailTextField.textColor = AppTheme.current.colors.activeElementColor
        emailTextField.tintColor = AppTheme.current.colors.mainElementColor
        emailTextField.backgroundColor = AppTheme.current.colors.foregroundColor
        emailTextField.layer.borderColor = UIColor.clear.cgColor
        emailTextField.keyboardAppearance = AppTheme.current.keyboardStyleForTheme
        emailSubtitleLabel.font = AppTheme.current.fonts.regular(13)
        emailSubtitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        recoverButton.setTitleColor(.white, for: .normal)
        recoverButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        loadingView.backgroundColor = AppTheme.current.colors.backgroundColor
    }
    
    private func showSuccessfullRecoverPasswordAlert(completion: @escaping () -> Void) {
        showAlert(title: "successfull_recover_password_alert_title".localized,
                  message: "successfull_recover_password_alert_message".localized,
                  actions: [.ok("Ok")],
                  completion: { _ in completion() })
    }
    
    private func showRecoverPasswordErrorAlert() {
        showAlert(title: "recover_password_error_alert_title".localized,
                  message: "recover_password_error_alert_message".localized,
                  actions: [.ok("Ok")],
                  completion: nil)
    }
    
    private func setupKeyboardManager() {
        keyboardManager.keyboardWillAppear = { [unowned self] frame, duration in
            self.view.layoutIfNeeded()
            self.recoverButtonBottomConstraint.constant = frame.height + 20
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
        
        keyboardManager.keyboardWillDisappear = { [unowned self] frame, duration in
            self.view.layoutIfNeeded()
            self.recoverButtonBottomConstraint.constant = 20
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
}

extension RecoverPasswordViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view === view
    }
    
}
