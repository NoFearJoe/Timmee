//
//  SwiftyStoreKit+AgileDiary.swift
//  Agile diary
//
//  Created by Илья Харабет on 11.05.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import StoreKit
import SwiftyStoreKit

extension SwiftyStoreKit {
    
    static func completeTransactions() {
        completeTransactions(atomically: true, completion: { _ in })
    }
    
    enum Subscription: String, CaseIterable {
        case monthly = "com.mesterra.AgileDiary.monthly.subscription"
        case annual = "com.mesterra.AgileDiary.annual.subscription"
    }
    
    static func retrieveSubscriptions(completion: @escaping (Result<[SKProduct], Error>) -> Void) {
        retrieveProductsInfo(Set(Subscription.allCases.map({ $0.rawValue }))) { result in
            if !result.retrievedProducts.isEmpty {
                completion(.success(Array(result.retrievedProducts)))
            } else {
                completion(.failure(result.error ?? SKError(.unknown)))
            }
        }
    }
    
    static func purchase(subscription: Subscription, completion: @escaping (PurchaseResult) -> Void) {
        purchaseProduct(subscription.rawValue) { result in
            verifySubscriptions { _ in
                completion(result)
            }
        }
    }

    static var hasUnexpiredSubscription: Bool {
        if let date = subscriptionExpirationDate, date.isGreater(than: .now) {
            return true
        } else {
            return false
        }
    }
    
    static func isSubscriptionPurchased(completion: @escaping (Bool) -> Void) {
        if ProVersionPurchase.shared.isPurchased() || hasUnexpiredSubscription {
            return completion(true)
        }
        
        SwiftyStoreKit.verifySubscriptions { result in
            switch result {
            case let .success(r):
                switch r {
                case .notPurchased, .expired:
                    completion(false)
                case .purchased:
                    completion(true)
                }
            case .failure:
                completion(false)
            }
        }
    }
    
    static func verifySubscriptions(completion: @escaping (Result<VerifySubscriptionResult, ReceiptError>) -> Void) {
        verifyReceipt(using: AppleReceiptValidator(service: .production, sharedSecret: "383395f7d82b493cacac438d8298490c")) { result in
            switch result {
            case let .success(receipt):
                let purchaseResult = verifySubscriptions(productIds: Set(Subscription.allCases.map({ $0.rawValue })), inReceipt: receipt)
                saveExpirationDate(result: purchaseResult)
                completion(.success(purchaseResult))
            case let .error(error):
                completion(.failure(error))
            }
        }
    }
    
    static func restoreSubscription(completion: @escaping (Bool) -> Void) {
        SwiftyStoreKit.restorePurchases { result in
            completion(result.restoreFailedPurchases.isEmpty)
        }
    }
    
    private static var subscriptionExpirationDate: Date? {
        get {
            UserDefaults.standard.object(forKey: "subscriptionExpirationDate") as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "subscriptionExpirationDate")
        }
    }
    
    private static func saveExpirationDate(result: VerifySubscriptionResult) {
        switch result {
        case let .purchased(expiryDate, _):
            subscriptionExpirationDate = expiryDate
        case let .expired(expiryDate, _):
            subscriptionExpirationDate = expiryDate
        case .notPurchased:
            subscriptionExpirationDate = nil
        }
    }
    
}
