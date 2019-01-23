//
//  AuthorizationViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 07.12.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import Authorization
import Synchronization

final class AuthorizationViewController: BaseViewController, AlertInput {
    
    // MARK: - Dependencies
    
    private let authorizationService = AuthorizationService()
    
    private var emailAndPasswordFieldsValidator: EmailAndPasswordFieldsValidator!
    
    private let keyboardManager = KeyboardManager()
    
    // MARK: - Outlets
    
    @IBOutlet private var headerView: LargeHeaderView!
    
    @IBOutlet private var emailTitleLabel: UILabel!
    @IBOutlet private var emailTextField: FocusableTextField!
    @IBOutlet private var passwordTitleLabel: UILabel!
    @IBOutlet private var passwordTextField: FocusableTextField!
    
    @IBOutlet private var facebookAuthorizationButton: UIButton!
    @IBOutlet private var googleAuthorizationButton: UIButton!
    
    @IBOutlet private var recoverPasswordButton: UIButton!
    @IBOutlet private var authorizationButton: ContinueEducationButton! // TODO: Не видно кнопку на 5s при поднятой клавиатуре
    @IBOutlet private var authorizationButtonBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private var loadingView: LoadingView!
    
    // MARK: - Actions
    
    @IBAction private func onTapToFacebookAuthorizationButton() {
        loadingView.isHidden = false
        authorizationService.performFacebookLogin(from: self) { [weak self] success in
            if success {
                self?.authorizationService.authorize(via: .facebook) { [weak self] success, error in
                    self?.loadingView.isHidden = true
                    if let error = error {
                        self?.showAuthorizationError(error)
                    } else if !success {
                        self?.showCommonAuthorizationError()
                    } else {
                        self?.dismiss(animated: true, completion: nil)
                    }
                }
            } else {
                self?.loadingView.isHidden = true
                self?.showCommonAuthorizationError()
            }
        }
    }
    
    @IBAction private func onTapToGoogleAuthorizationButton() {
        
    }
    
    @IBAction private func onTapToAuthorizationButton() {
        guard let email = emailTextField.text?.trimmed, !email.isEmpty else { return }
        guard let password = passwordTextField.text?.trimmed, !password.isEmpty else { return }
        
        loadingView.isHidden = false
        authorizationService.authorize(via: .emailAndPassword(email: email, password: password)) { [weak self] success, error in
            self?.loadingView.isHidden = true
            if let error = error {
                self?.showAuthorizationError(error)
            } else if !success {
                self?.showCommonAuthorizationError()
            } else {
                SynchronizationService.shared.sync { isSuccess in
                    print("::: sync \(isSuccess)")
                }
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction private func onTapToRecoverPasswordButton() {
        
    }
    
    @IBAction private func onTapToCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func onTapToBackgroundView() {
        view.endEditing(true)
    }
    
    // MARK: - Lifecycle
    
    override func prepare() {
        super.prepare()
        
        setupKeyboardManager()
        
        headerView.titleLabel.text = "authorization".localized
        emailTitleLabel.text = "e-mail".localized
        passwordTitleLabel.text = "password".localized
        recoverPasswordButton.setTitle("recover_password".localized, for: .normal)
        authorizationButton.setTitle("authorize".localized, for: .normal)
        
        authorizationButton.isEnabled = false
        
        emailAndPasswordFieldsValidator = EmailAndPasswordFieldsValidator(emailTextField: emailTextField,
                                                                          passwordTextField: passwordTextField,
                                                                          onValid: { [unowned self] isValid in
                                                                              self.authorizationButton.isEnabled = isValid
                                                                          })
    }
    
    override func refresh() {
        super.refresh()
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
        passwordTitleLabel.font = AppTheme.current.fonts.regular(16)
        passwordTitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        passwordTextField.font = AppTheme.current.fonts.bold(18)
        passwordTextField.textColor = AppTheme.current.colors.activeElementColor
        passwordTextField.tintColor = AppTheme.current.colors.mainElementColor
        passwordTextField.backgroundColor = AppTheme.current.colors.foregroundColor
        passwordTextField.layer.borderColor = UIColor.clear.cgColor
        passwordTextField.keyboardAppearance = AppTheme.current.keyboardStyleForTheme
        recoverPasswordButton.setTitleColor(AppTheme.current.colors.activeElementColor, for: .normal)
        recoverPasswordButton.titleLabel?.font = AppTheme.current.fonts.regular(13)
        authorizationButton.setTitleColor(.white, for: .normal)
        authorizationButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        loadingView.backgroundColor = AppTheme.current.colors.backgroundColor
    }
    
    private func showAuthorizationError(_ error: AuthorizationError) {
        switch error {
        case .wrongPassword:
            showAlert(title: "wrong_password_alert_title".localized,
                      message: "wrong_password_alert_message".localized,
                      actions: [.ok("Ok")],
                      completion: nil)
        case .invalidEmail:
            showAlert(title: "invalid_email_alert_title".localized,
                      message: "invalid_email_alert_message".localized,
                      actions: [.ok("Ok")],
                      completion: nil)
        case let .invalidPassword(errorMessage):
            showAlert(title: "invalid_password_alert_title".localized,
                      message: errorMessage,
                      actions: [.ok("Ok")],
                      completion: nil)
        }
    }
    
    private func showCommonAuthorizationError() {
        showAlert(title: "common_authorization_error_title".localized,
                  message: "common_authorization_error_message".localized,
                  actions: [.ok("Ok")],
                  completion: nil)
    }
    
    private func setupKeyboardManager() {
        keyboardManager.keyboardWillAppear = { [unowned self] frame, duration in
            self.view.layoutIfNeeded()
            self.authorizationButtonBottomConstraint.constant = frame.height + 20
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
        
        keyboardManager.keyboardWillDisappear = { [unowned self] frame, duration in
            self.view.layoutIfNeeded()
            self.authorizationButtonBottomConstraint.constant = 20
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
}

extension AuthorizationViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view === view
    }
    
}
