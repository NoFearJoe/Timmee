//
//  FirebaseTypesProtocols.swift
//  Synchronization
//
//  Created by Илья Харабет on 15/03/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import Foundation

public protocol FirebaseFirestoreProtocol {
    func _collection(_ collectionPath: String) -> FirebaseFirestoreCollectionProtocol
    func _batch() -> FirebaseFirestoreBatchProtocol
}

public protocol FirebaseFirestoreCollectionProtocol {
    func _document(_ documentPath: String) -> FirebaseFirestoreDocumentProtocol
    func _getDocuments(completion: ((FirebaseFirestoreQueryDocumentSnapshotProtocol?, Error?) -> Void)?)
}

public protocol FirebaseFirestoreDocumentProtocol {
    func _getDocument(completion: ((FirebaseFirestoreDocumentSnapshotProtocol?, Error?) -> Void)?)
    func _collection(_ collectionPath: String) -> FirebaseFirestoreCollectionProtocol
}

public protocol FirebaseFirestoreDocumentSnapshotProtocol {
    func _data() -> [String: Any]?
    var _reference: FirebaseFirestoreDocumentReferenceProtocol { get }
}

public protocol FirebaseFirestoreQueryDocumentSnapshotProtocol {
    var _documents: [FirebaseFirestoreDocumentSnapshotProtocol] { get }
}

public protocol FirebaseFirestoreBatchProtocol {
    func _setData(_ data: [String: Any], forDocument document: Any)
    func _deleteDocument(_ document: Any)
    func _commit(completion: ((Error?) -> Void)?)
}

public protocol FirebaseFirestoreDocumentReferenceProtocol {
    func _collection(_ collectionPath: String) -> FirebaseFirestoreCollectionProtocol
}

public protocol FirebaseFirestoreTimestampProtocol {
    func dateValue() -> Date
}
