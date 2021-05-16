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
        completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    
                    UserDefaults.standard.set(true, forKey: purchase.productId)
                case .failed, .purchasing, .deferred:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    enum Subscription: String, CaseIterable {
        case monthly = "com.mesterra.AgileDiary.monthly.subscription"
        case annual = "com.mesterra.AgileDiary.annual.subscription"
    }
    
    static var isSubscriptionPurchased: Bool {
        ProVersionPurchase.shared.isPurchased() || Subscription.allCases.contains(where: { UserDefaults.standard.bool(forKey: $0.rawValue) })
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
            completion(result)
        }
    }
    
    static func verifySubscriptions(completion: @escaping (Result<VerifySubscriptionResult, ReceiptError>) -> Void) {
        verifyReceipt(using: AppleReceiptValidator(service: .production, sharedSecret: "383395f7d82b493cacac438d8298490c")) { result in
            switch result {
            case let .success(receipt):
                let purchaseState = verifySubscriptions(productIds: Set(Subscription.allCases.map({ $0.rawValue })), inReceipt: receipt)
                completion(.success(purchaseState))
            case let .error(error):
                completion(.failure(error))
            }
        }
    }
    
    static func restoreSubscription(completion: @escaping (Bool) -> Void) {
        SwiftyStoreKit.restorePurchases { result in
            result.restoredPurchases.forEach {
                UserDefaults.standard.set(true, forKey: $0.productId)
            }
            
            completion(result.restoreFailedPurchases.isEmpty)
        }
    }
    
}
