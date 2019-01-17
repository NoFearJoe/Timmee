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

// TODO: Использовать отдельные валидаторы
final class EmailAndPasswordFieldsValidator: NSObject {
    
    private let onValid: (Bool) -> Void
    
    private unowned let emailTextField: UITextField
    private unowned let passwordTextField: UITextField
    
    init(emailTextField: UITextField, passwordTextField: UITextField, onValid: @escaping (Bool) -> Void) {
        self.onValid = onValid
        self.emailTextField = emailTextField
        self.passwordTextField = passwordTextField
        
        super.init()
        
        emailTextField.addTarget(self, action: #selector(validateFields), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(validateFields), for: .editingChanged)
    }
    
    @objc private func validateFields() {
        let email = emailTextField.text?.trimmed ?? ""
        let password = passwordTextField.text?.trimmed ?? ""
        
        let emailIsValid = EmailValidator.validate(email: email).isValid
        let passwordIsValid = PasswordValidator.validate(password: password).isValid
        
        let isFieldsValid = emailIsValid && passwordIsValid
        
        onValid(isFieldsValid)
    }
    
}
