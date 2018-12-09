//
//  AuthorizationViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 07.12.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import Authorization

final class AuthorizationViewController: BaseViewController {
    
    // MARK: - Dependencies
    
    private let authorizationService = AuthorizationService()
    
    // MARK: - Outlets
    
    @IBOutlet private var headerView: LargeHeaderView!
    
    @IBOutlet private var emailTitleLabel: UILabel!
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var passwordTitleLabel: UILabel!
    @IBOutlet private var passwordTextField: UITextField!
    
    @IBOutlet private var facebookAuthorizationButton: UIButton!
    @IBOutlet private var googleAuthorizationButton: UIButton!
    
    @IBOutlet private var authorizationButton: ContinueEducationButton!
    
    // MARK: - Actions
    
    @IBAction private func onTapToFacebookAuthorizationButton() {
        // TODO: Loading
        authorizationService.performFacebookLogin(from: self) { [weak self] success in
            if success {
                self?.authorizationService.authorize(via: .facebook) { [weak self] success in
                    // TODO
                }
            } else {
                // TODO
            }
        }
    }
    
    @IBAction private func onTapToGoogleAuthorizationButton() {
        
    }
    
    @IBAction private func onTapToAuthorizationButton() {
        guard let email = emailTextField.text?.trimmed, !email.isEmpty else { return }
        guard let password = passwordTextField.text?.trimmed, !password.isEmpty else { return }
        // TODO: Loading
        authorizationService.authorize(via: .emailAndPassword(email: email, password: password)) { [weak self] success in
            // TODO
        }
    }
    
    @IBAction private func onTapToCloseButton() {
        
    }
    
    @IBAction private func onTapToBackgroundView() {
        view.endEditing(true)
    }
    
    // MARK: - Lifecycle
    
    override func prepare() {
        super.prepare()
        
        headerView.titleLabel.text = "authorization".localized
        emailTitleLabel.text = "e-mail".localized
        passwordTitleLabel.text = "password".localized
        authorizationButton.setTitle("authorize".localized, for: .normal)
    }
    
    override func refresh() {
        super.refresh()
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        emailTitleLabel.font = AppTheme.current.fonts.medium(18)
        emailTitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        emailTextField.font = AppTheme.current.fonts.bold(18)
        emailTextField.textColor = AppTheme.current.colors.activeElementColor
        emailTextField.tintColor = AppTheme.current.colors.mainElementColor
        emailTextField.backgroundColor = AppTheme.current.colors.foregroundColor
        emailTextField.layer.borderColor = UIColor.clear.cgColor
        emailTextField.keyboardAppearance = AppTheme.current.keyboardStyleForTheme
        passwordTitleLabel.font = AppTheme.current.fonts.medium(18)
        passwordTitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        passwordTextField.font = AppTheme.current.fonts.bold(18)
        passwordTextField.textColor = AppTheme.current.colors.activeElementColor
        passwordTextField.tintColor = AppTheme.current.colors.mainElementColor
        passwordTextField.backgroundColor = AppTheme.current.colors.foregroundColor
        passwordTextField.layer.borderColor = UIColor.clear.cgColor
        passwordTextField.keyboardAppearance = AppTheme.current.keyboardStyleForTheme
        authorizationButton.setTitleColor(.white, for: .normal)
        authorizationButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
    }
    
}

extension AuthorizationViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view === view
    }
    
}
