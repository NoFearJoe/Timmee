//
//  SynchronizationConfigurator.swift
//  Agile diary
//
//  Created by i.kharabet on 08.02.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import Firebase
import Authorization
import Synchronization

final class SynchronizationConfigurator {
    
    static func configure() {
        guard let app = FirebaseApp.app() else { return }
        
        AuthorizationService.initializeAuthorization(auth: Firebase.Auth.auth())
        AgileeSynchronizationService.initializeSynchronization(firestore: firestore(app: app))
        SynchronizationAvailabilityChecker.shared.checkSynchronizationConditions = {
            ProVersionPurchase.shared.isPurchased()
        }
    }
    
    private static func firestore(app: FirebaseApp) -> Firestore {
        let firestore = Firestore.firestore(app: app)

        let settings = firestore.settings
        settings.isPersistenceEnabled = false
        firestore.settings = settings

        return firestore
    }
    
}

import Firebase
import FirebaseAuth

extension Firebase.User: FirebaseUserProtocol {}

extension Firebase.Auth: FirebaseAuthProtocol {

    public var user: FirebaseUserProtocol? {
        currentUser
    }

    public func signIn(withEmail email: String, password: String, completion: ((Bool, Error?) -> Void)?) {
        signIn(withEmail: email, password: password) { result, error in
            completion?(result != nil, error)
        }
    }

    public func signIn(withFacebookAccessToken token: String, completion: ((Bool, Error?) -> Void)?) {
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        signIn(with: credential) { result, error in
            completion?(result != nil, error)
        }
    }

    public func createUser(withEmail email: String, password: String, completion: ((Bool, Error?) -> Void)?) {
        createUser(withEmail: email, password: password) { result, error in
            completion?(result != nil, error)
        }
    }

    public func verifyPasswordResetCode(_ code: String, completion: ((String?, Error?) -> Void)?) {
        verifyPasswordResetCode(code) { code, error in
            completion?(code, error)
        }
    }

    public func confirmPasswordReset(withCode code: String, newPassword: String, completion: ((Error?) -> Void)?) {
        confirmPasswordReset(withCode: code, newPassword: newPassword) { error in
            completion?(error)
        }
    }

}

extension Firebase.Firestore: FirebaseFirestoreProtocol {
    
    public func _collection(_ collectionPath: String) -> FirebaseFirestoreCollectionProtocol {
        collection(collectionPath) as CollectionReference
    }
    
    public func _batch() -> FirebaseFirestoreBatchProtocol {
        batch() as WriteBatch
    }
    
}

extension Firebase.CollectionReference: FirebaseFirestoreCollectionProtocol {
    
    public func _document(_ documentPath: String) -> FirebaseFirestoreDocumentProtocol {
        document(documentPath) as DocumentReference
    }
    
    public func _getDocuments(completion: ((FirebaseFirestoreQueryDocumentSnapshotProtocol?, Error?) -> Void)?) {
        getDocuments { snapshot, error in
            completion?(snapshot, error)
        }
    }
    
}

extension Firebase.DocumentReference: FirebaseFirestoreDocumentProtocol {
    
    public func _getDocument(completion: ((FirebaseFirestoreDocumentSnapshotProtocol?, Error?) -> Void)?) {
        getDocument { snapshot, error in
            completion?(snapshot, error)
        }
    }
    
    public func _collection(_ collectionPath: String) -> FirebaseFirestoreCollectionProtocol {
        collection(collectionPath) as CollectionReference
    }
    
}

extension Firebase.DocumentReference: FirebaseFirestoreDocumentReferenceProtocol {}

extension Firebase.DocumentSnapshot: FirebaseFirestoreDocumentSnapshotProtocol {
    
    public func _data() -> [String : Any]? {
        data()
    }
    
    public var _reference: FirebaseFirestoreDocumentReferenceProtocol {
        reference
    }
    
}

extension Firebase.QuerySnapshot: FirebaseFirestoreQueryDocumentSnapshotProtocol {
    
    public var _documents: [FirebaseFirestoreDocumentSnapshotProtocol] {
        documents
    }
    
}

extension Firebase.WriteBatch: FirebaseFirestoreBatchProtocol {
    
    public func _setData(_ data: [String : Any], forDocument document: Any) {
        guard let document = document as? DocumentReference else { return }
        setData(data, forDocument: document)
    }
    
    public func _deleteDocument(_ document: Any) {
        guard let document = document as? DocumentReference else { return }
        deleteDocument(document)
    }
    
    public func _commit(completion: ((Error?) -> Void)?) {
        commit(completion: completion)
    }
    
}

extension Firebase.Timestamp: FirebaseFirestoreTimestampProtocol {}
