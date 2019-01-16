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
    
    @IBOutlet private var headerView: LargeHeaderView!
    
    @IBOutlet private var emailTitleLabel: UILabel!
    @IBOutlet private var emailTextField: FocusableTextField!
    @IBOutlet private var emailSubtitleLabel: UILabel!
    
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var recoverButton: ContinueEducationButton! // TODO: Клавиатура не поднимает кнопку
    
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
        
        recoverButton.setTitle("recover_password".localized, for: .normal)
        
        recoverButton.isEnabled = false
        
        emailFieldValidator = EmailFieldValidator(emailTextField: emailTextField, onValid: { [unowned self] isValid in
            self.recoverButton.isEnabled = isValid
        })
        
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
    
    private func showRecoverPasswordErrorAlert() {
        showAlert(title: "recover_password_error_alert_title".localized,
                  message: "recover_password_error_alert_message".localized,
                  actions: [.ok("Ok")],
                  completion: nil)
    }
    
}

extension RecoverPasswordViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view === view
    }
    
}
