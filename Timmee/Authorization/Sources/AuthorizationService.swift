//
//  AuthorizationService.swift
//  Authorization
//
//  Created by Илья Харабет on 09/12/2018.
//  Copyright © 2018 Илья Харабет. All rights reserved.
//

import Firebase
import FBSDKLoginKit

public enum AuthorizationType {
    case emailAndPassword(email: String, password: String)
    case facebook
}

public final class AuthorizationService {
    
    public init() {}
    
    public func authorize(via type: AuthorizationType, completion: @escaping (Bool) -> Void) {
        switch type {
        case let .emailAndPassword(email, password):
            Firebase.Auth.auth().signIn(withEmail: email, password: password) { result, error in
                let isSuccess = error == nil && result != nil
                completion(isSuccess)
            }
        case .facebook:
            guard let token = FBSDKAccessToken.current()?.tokenString else { completion(false); return }
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            Firebase.Auth.auth().signInAndRetrieveData(with: credential) { result, error in
                let isSuccess = error == nil && result != nil
                completion(isSuccess)
            }
        }
    }
    
    public func performFacebookLogin(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        FBSDKLoginManager().logIn(withReadPermissions: [""], from: viewController) { result, error in
            let isSuccess = result != nil && !result!.isCancelled && error == nil
            completion(isSuccess)
        }
    }
    
}
