//
//  NewPasswordViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 17.01.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import Authorization

final class NewPasswordViewController: BaseViewController, AlertInput {
    
    private let authorizationService = AuthorizationService()
    
    private var passwordFieldValidator: PasswordFieldValidator!
    
    @IBOutlet private var headerView: LargeHeaderView!
    
    @IBOutlet private var verificationCodeTitleLabel: UILabel!
    @IBOutlet private var verificationCodeTextField: FocusableTextField!
    @IBOutlet private var verificationCodeSubtitleLabel: UILabel!
    
    @IBOutlet private var passwordTitleLabel: UILabel!
    @IBOutlet private var passwordTextField: FocusableTextField!
    
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var recoverButton: ContinueEducationButton! // TODO: Клавиатура не поднимает кнопку
    
    @IBOutlet private var loadingView: LoadingView!
    
    @IBAction private func onTapToCloseButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func onTapToRecoverButton() {
        guard let code = verificationCodeTextField.text?.trimmed.nilIfEmpty else { return }
        guard let password = passwordTextField.text?.trimmed.nilIfEmpty else { return }
        loadingView.isHidden = false
        authorizationService.recoverPassword(verificationCode: code,
                                             newPassword: password,
                                             completion: { [weak self] success in
                                                 self?.loadingView.isHidden = true
                                                
                                                 if success {
                                                     self?.navigationController?.dismiss(animated: true, completion: nil)
                                                 } else {
                                                     self?.showNewPasswordErrorAlert()
                                                 }
                                             })
    }
    
    @IBAction private func onTapToBackgroundView() {
        view.endEditing(true)
    }
    
    override func prepare() {
        super.prepare()
        
        recoverButton.setTitle("recover_password".localized, for: .normal)
        
        recoverButton.isEnabled = false
        
        passwordFieldValidator = PasswordFieldValidator(passwordTextField: passwordTextField, onValid: { [unowned self] isValid in
            self.recoverButton.isEnabled = isValid
        })
        
        if !verificationCodeTextField.isFirstResponder {
            verificationCodeTextField.becomeFirstResponder()
        }
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        verificationCodeTitleLabel.font = AppTheme.current.fonts.regular(16)
        verificationCodeTitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        verificationCodeTextField.font = AppTheme.current.fonts.bold(18)
        verificationCodeTextField.textColor = AppTheme.current.colors.activeElementColor
        verificationCodeTextField.tintColor = AppTheme.current.colors.mainElementColor
        verificationCodeTextField.backgroundColor = AppTheme.current.colors.foregroundColor
        verificationCodeTextField.layer.borderColor = UIColor.clear.cgColor
        verificationCodeTextField.keyboardAppearance = AppTheme.current.keyboardStyleForTheme
        verificationCodeSubtitleLabel.font = AppTheme.current.fonts.regular(13)
        verificationCodeSubtitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        passwordTitleLabel.font = AppTheme.current.fonts.regular(16)
        passwordTitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        passwordTextField.font = AppTheme.current.fonts.bold(18)
        passwordTextField.textColor = AppTheme.current.colors.activeElementColor
        passwordTextField.tintColor = AppTheme.current.colors.mainElementColor
        passwordTextField.backgroundColor = AppTheme.current.colors.foregroundColor
        passwordTextField.layer.borderColor = UIColor.clear.cgColor
        passwordTextField.keyboardAppearance = AppTheme.current.keyboardStyleForTheme
        recoverButton.setTitleColor(.white, for: .normal)
        recoverButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        loadingView.backgroundColor = AppTheme.current.colors.backgroundColor
    }
    
    private func showNewPasswordErrorAlert() {
        showAlert(title: "new_password_error_alert_title".localized,
                  message: "new_password_error_alert_message".localized,
                  actions: [.ok("Ok")],
                  completion: nil)
    }
    
}
