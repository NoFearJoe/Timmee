//
//  AuthorizationService.swift
//  Authorization
//
//  Created by Илья Харабет on 09/12/2018.
//  Copyright © 2018 Илья Харабет. All rights reserved.
//

import FBSDKLoginKit

public struct User {
    public let id: String
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

public protocol FirebaseUserProtocol {
    var uid: String { get }
    var email: String? { get }
    var displayName: String? { get }
}

public protocol FirebaseAuthProtocol {
    var user: FirebaseUserProtocol? { get }

    func signIn(withEmail email: String, password: String, completion: ((Bool, Error?) -> Void)?)
    func signIn(withFacebookAccessToken token: String, completion: ((Bool, Error?) -> Void)?)
    func createUser(withEmail email: String, password: String, completion: ((Bool, Error?) -> Void)?)
    func sendPasswordReset(withEmail email: String, completion: ((Error?) -> Void)?)
    func verifyPasswordResetCode(_ code: String, completion: ((String?, Error?) -> Void)?)
    func confirmPasswordReset(withCode code: String, newPassword: String, completion: ((Error?) -> Void)?)
    func signOut() throws
}

public final class AuthorizationService {
    
    public static func initializeAuthorization(auth: FirebaseAuthProtocol) {
        Self.auth = auth
    }
    
    private static var auth: FirebaseAuthProtocol!
    
    private let auth: FirebaseAuthProtocol
    private let authorizationStatusStorage = AuthorizationStatusStorage.shared
    
    public init() {
        self.auth = Self.auth
        authorizationStatusStorage.auth = auth
    }
    
    public var isAuthorized: Bool {
        return authorizationStatusStorage.userIsAuthorized
    }
    
    public var canAuthorizeWithSavedCredentials: Bool {
        return authorizationStatusStorage.userHasBeenAuthorized
    }
    
    public var authorizedUser: User? {
        guard let currentUser = auth.user else { return nil }
        return User(id: currentUser.uid, email: currentUser.email, name: currentUser.displayName)
    }
    
    // MARK: - Авторизация
    
    public func authorize(via type: AuthorizationType, completion: @escaping (Bool, AuthorizationError?) -> Void) {
        if isAuthorized {
            completion(true, nil)
            return
        }
        switch type {
        case let .emailAndPassword(email, password):
            auth.signIn(withEmail: email, password: password) { [weak self] result, error in
                guard let self = self else { return }
                
                let isSuccess = error == nil && result
                let authorizationError = self.convertFirebaseErrorToAuthorizationError(error)

                if !isSuccess, authorizationError == nil || authorizationError != .wrongPassword {
                    self.auth.createUser(withEmail: email, password: password, completion: { result, error in
                        let isSuccess = error == nil && result
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
            guard let token = AccessToken.current?.tokenString else { completion(false, nil); return }
            auth.signIn(withFacebookAccessToken: token) { result, error in
                let isSuccess = error == nil && result
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
        auth.sendPasswordReset(withEmail: email) { error in
            completion(error == nil)
        }
    }
    
    public func recoverPassword(verificationCode: String, newPassword: String, completion: @escaping (Bool) -> Void) {
        auth.verifyPasswordResetCode(verificationCode) { [weak self] email, error in
            guard let self = self, error == nil else {
                completion(false)
                return
            }
            self.auth.confirmPasswordReset(
                withCode: verificationCode,
                newPassword: newPassword,
                completion: { error in completion(error == nil) }
            )
        }
    }
    
    // MARK: - Выход
    
    public func unauthorize(completion: @escaping () -> Void) {
        try? auth.signOut()
        authorizationStatusStorage.commitUnauthorization()
        completion()
    }
    
    public func performFacebookLogin(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        LoginManager().logIn(permissions: [""], from: viewController) { result, error in
            let isSuccess = result != nil && !result!.isCancelled && error == nil
            completion(isSuccess)
        }
    }
    
    private func convertFirebaseErrorToAuthorizationError(_ error: Error?) -> AuthorizationError? {
        guard let error = error as NSError? else { return nil }
        switch error.code {
        case 17009: return .wrongPassword
        case 17008: return .invalidEmail
        case 17026:
            let errorMessage = error.userInfo[NSLocalizedFailureReasonErrorKey] as? String
            return .invalidPassword(errorMessage)
        default: return nil
        }
    }
    
}
