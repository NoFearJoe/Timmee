//
//  EmailAndPasswordFieldsValidator.swift
//  Agile diary
//
//  Created by i.kharabet on 15.01.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

class EmailFieldValidator: NSObject {
    private let onValid: (Bool) -> Void
    
    private unowned let emailTextField: UITextField
    
    init(emailTextField: UITextField, onValid: @escaping (Bool) -> Void) {
        self.onValid = onValid
        self.emailTextField = emailTextField
        
        super.init()
        
        emailTextField.addTarget(self, action: #selector(validateField), for: .editingChanged)
    }
    
    @objc private func validateField() {
        let email = emailTextField.text?.trimmed ?? ""
        
        let emailIsValid = EmailValidator.validate(email: email).isValid
        
        onValid(emailIsValid)
    }
}

class PasswordFieldValidator: NSObject {
    private let onValid: (Bool) -> Void
    
    private unowned let passwordTextField: UITextField
    
    init(passwordTextField: UITextField, onValid: @escaping (Bool) -> Void) {
        self.onValid = onValid
        self.passwordTextField = passwordTextField
        
        super.init()
        
        passwordTextField.addTarget(self, action: #selector(validateField), for: .editingChanged)
    }
    
    @objc private func validateField() {
        let password = passwordTextField.text?.trimmed ?? ""
        
        let passwordIsValid = PasswordValidator.validate(password: password).isValid
        
        onValid(passwordIsValid)
    }
}

final class EmailAndPasswordFieldsValidator: NSObject {
    
    private let onValid: (Bool) -> Void
    
    private var emailFieldValidator: EmailFieldValidator!
    private var passwordFieldValidator: PasswordFieldValidator!
    
    private var emailIsValid = false
    private var passwordIsValid = false
    
    init(emailTextField: UITextField, passwordTextField: UITextField, onValid: @escaping (Bool) -> Void) {
        self.onValid = onValid
        
        super.init()
        
        self.emailFieldValidator = EmailFieldValidator(emailTextField: emailTextField, onValid: { [unowned self] isValid in
            self.emailIsValid = isValid
            self.onValid(self.emailIsValid && self.passwordIsValid)
        })
        self.passwordFieldValidator = PasswordFieldValidator(passwordTextField: passwordTextField, onValid: { [unowned self] isValid in
            self.passwordIsValid = isValid
            self.onValid(self.emailIsValid && self.passwordIsValid)
        })
    }
    
}
