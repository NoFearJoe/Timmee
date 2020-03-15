//
//  AuthorizationStatusStorage.swift
//  Authorization
//
//  Created by i.kharabet on 16.01.2019.
//  Copyright © 2019 Илья Харабет. All rights reserved.
//

import Workset

final class AuthorizationStatusStorage {
    
    static let shared = AuthorizationStatusStorage()
    
    var auth: FirebaseAuthProtocol!
    
    private init() {}
    
    /// Возвращает true, если пользователь авторизован
    var userIsAuthorized: Bool {
        auth.user != nil
    }
    
    /// Возвращает true, если пользователь когда-то был авторизован
    /// Используется когда сессия истекла, но есть данные для повторной авторизации
    var userHasBeenAuthorized: Bool {
        return UserDefaults.standard.bool(forKey: Keys.userHasBeenAuthorized)
    }
    
    var savedAuthorizationCredentials: AuthorizationType? {
        guard let savedAuthorizationType = UserDefaults.standard.string(forKey: Keys.userAuthorizationType) else { return nil }
        switch savedAuthorizationType {
        case AuthorizationType.emailAndPassword(email: "", password: "").string:
            guard let email = Keychain.read(Keys.userEmail) else { return nil }
            guard let password = Keychain.read(Keys.userPassword) else { return nil }
            return .emailAndPassword(email: email, password: password)
        case AuthorizationType.facebook.string:
            return .facebook
        default:
            return nil
        }
    }
    
    func commitAuthorization(type: AuthorizationType, userInfo: [String: Any]) {
        UserDefaults.standard.set(true, forKey: Keys.userHasBeenAuthorized)
        UserDefaults.standard.set(type.string, forKey: Keys.userAuthorizationType)
        
        switch type {
        case let .emailAndPassword(email, password):
            Keychain.save(Keys.userEmail, value: email)
            Keychain.save(Keys.userPassword, value: password)
        case .facebook: break
        }
    }
    
    func commitUnauthorization() {
        UserDefaults.standard.set(false, forKey: Keys.userHasBeenAuthorized)
        UserDefaults.standard.set(nil, forKey: Keys.userAuthorizationType)
        
        Keychain.delete(Keys.userEmail)
        Keychain.delete(Keys.userPassword)
    }
    
    private struct Keys {
        static let userHasBeenAuthorized = "user_has_been_authorized"
        static let userAuthorizationType = "user_authorization_type"
        static let userEmail = "user_email"
        static let userPassword = "user_password"
    }
    
}
