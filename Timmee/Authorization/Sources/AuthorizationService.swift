//
//  AuthorizationService.swift
//  Authorization
//
//  Created by Илья Харабет on 09/12/2018.
//  Copyright © 2018 Илья Харабет. All rights reserved.
//

import Firebase
import FBSDKLoginKit

public struct User {
    public let email: String?
    public let name: String?
    
    public var nameOrEmail: String? {
        return name ?? email
    }
}

public enum AuthorizationType {
    case emailAndPassword(email: String, password: String)
    case facebook
    
    var string: String {
        switch self {
        case .emailAndPassword: return "email_and_password"
        case .facebook: return "facebook"
        }
    }
}

public enum AuthorizationError: Equatable {
    case wrongPassword, invalidEmail
    case invalidPassword(String?)
    
    public static func == (lhs: AuthorizationError, rhs: AuthorizationError) -> Bool {
        switch (lhs, rhs) {
        case (.wrongPassword, .wrongPassword), (.invalidEmail, .invalidEmail), (.invalidPassword, .invalidPassword): return true
        default: return false
        }
    }
}

public final class AuthorizationService {
    
    public static func initializeAuthorization() {
        FirebaseApp.configure()
    }
    
    private let authorizationStatusStorage = AuthorizationStatusStorage.shared
    
    public init() {}
    
    public var isAuthorized: Bool {
        return authorizationStatusStorage.userIsAuthorized
    }
    
    public var canAuthorizeWithSavedCredentials: Bool {
        return authorizationStatusStorage.userHasBeenAuthorized
    }
    
    public var authorizedUser: User? {
        guard let currentUser = Firebase.Auth.auth().currentUser else { return nil }
        return User(email: currentUser.email, name: currentUser.displayName)
    }
    
    // MARK: - Авторизация
    
    public func authorize(via type: AuthorizationType, completion: @escaping (Bool, AuthorizationError?) -> Void) {
        if isAuthorized {
            completion(true, nil)
            return
        }
        switch type {
        case let .emailAndPassword(email, password):
            Firebase.Auth.auth().signIn(withEmail: email, password: password) { result, error in
                let isSuccess = error == nil && result != nil
                let authorizationError = self.convertFirebaseErrorToAuthorizationError(error)

                if !isSuccess, authorizationError == nil || authorizationError != .wrongPassword {
                    Firebase.Auth.auth().createUser(withEmail: email, password: password, completion: { result, error in
                        let isSuccess = error == nil && result != nil
                        if isSuccess {
                            self.authorizationStatusStorage.commitAuthorization(type: type, userInfo: [:])
                        }
                        let authorizationError = self.convertFirebaseErrorToAuthorizationError(error)
                        completion(isSuccess, authorizationError)
                    })
                } else {
                    if isSuccess {
                        self.authorizationStatusStorage.commitAuthorization(type: type, userInfo: [:])
                    }
                    completion(isSuccess, authorizationError)
                }
            }
        case .facebook:
            guard let token = FBSDKAccessToken.current()?.tokenString else { completion(false, nil); return }
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            Firebase.Auth.auth().signInAndRetrieveData(with: credential) { result, error in
                let isSuccess = error == nil && result != nil
                if isSuccess {
                    self.authorizationStatusStorage.commitAuthorization(type: type, userInfo: [:])
                }
                let authorizationError = self.convertFirebaseErrorToAuthorizationError(error)
                completion(isSuccess, authorizationError)
            }
        }
    }
    
    public func authorizeWithSavedCredentials(completion: @escaping (Bool, AuthorizationError?) -> Void) {
        guard !isAuthorized, canAuthorizeWithSavedCredentials else {
            completion(isAuthorized, nil)
            return
        }
        
        guard let savedCredentials = authorizationStatusStorage.savedAuthorizationCredentials else {
            completion(false, nil)
            return
        }
        
        authorize(via: savedCredentials, completion: completion)
    }
    
    // MARK: - Восстановление пароля
    
    public func initiatePasswordRecover(email: String, completion: @escaping (Bool) -> Void) {
        Firebase.Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error == nil)
        }
    }
    
    public func recoverPassword(verificationCode: String, newPassword: String, completion: @escaping (Bool) -> Void) {
        Firebase.Auth.auth().verifyPasswordResetCode(verificationCode) { email, error in
            guard error == nil else {
                completion(false)
                return
            }
            Firebase.Auth.auth().confirmPasswordReset(withCode: verificationCode,
                                                      newPassword: newPassword,
                                                      completion: { error in completion(error == nil) })
        }
    }
    
    // MARK: - Выход
    
    public func unauthorize(completion: @escaping () -> Void) {
        try? Firebase.Auth.auth().signOut()
        authorizationStatusStorage.commitUnauthorization()
        completion()
    }
    
    public func performFacebookLogin(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        FBSDKLoginManager().logIn(withReadPermissions: [""], from: viewController) { result, error in
            let isSuccess = result != nil && !result!.isCancelled && error == nil
            completion(isSuccess)
        }
    }
    
    private func convertFirebaseErrorToAuthorizationError(_ error: Error?) -> AuthorizationError? {
        guard let error = error as NSError? else { return nil }
        switch error.code {
        case Firebase.AuthErrorCode.wrongPassword.rawValue: return .wrongPassword
        case Firebase.AuthErrorCode.invalidEmail.rawValue: return .invalidEmail
        case Firebase.AuthErrorCode.weakPassword.rawValue:
            let errorMessage = error.userInfo[NSLocalizedFailureReasonErrorKey] as? String
            return .invalidPassword(errorMessage)
        default: return nil
        }
    }
    
}
