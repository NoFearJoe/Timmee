//
//  PasswordValidator.swift
//  Agile diary
//
//  Created by i.kharabet on 15.01.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

final class PasswordValidator {
    
    private static let minimumPasswordLength = 6
    
    enum ValidationResult {
        case valid
        case passwordIsTooShort
        
        var isValid: Bool {
            return self == .valid
        }
    }
    
    static func validate(password: String) -> ValidationResult {
        if password.count < minimumPasswordLength {
            return .passwordIsTooShort
        }
        return .valid
    }
    
}
