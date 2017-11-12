//
//  InAppPurchase.swift
//  Timmee
//
//  Created by Ilya Kharabet on 06.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import StoreKit

final class InAppPurchase: NSObject {
    
    var product: SKProduct?
    var request: SKProductsRequest?
    
    let id: String
    
    var isLoading = false
    
    fileprivate var completion: (() -> Void)?
    fileprivate var productDataObtained: (() -> Void)?
    var restoreCompletion: (() -> Void)?
    
    static let abstract = InAppPurchase(id: "")
    
    init(id: String) {
        self.id = id
    }
    
    func loadStore() {
        SKPaymentQueue.default().add(self)
    }
    
    func requestData(completion: @escaping () -> Void) {
        self.productDataObtained = completion
        
        let idSet = Set(arrayLiteral: id)
        request = SKProductsRequest(productIdentifiers: idSet)
        request?.delegate = self
        request?.start()
        
        isLoading = true
    }
    
    func canPurchase() -> Bool {
        return SKPaymentQueue.canMakePayments() && product != nil
    }
    
    func purchase(completion: @escaping () -> Void) {
        self.completion = completion
        if let product = self.product, canPurchase() {
            isLoading = true
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func restore(completion: @escaping () -> Void) {
        self.restoreCompletion = completion
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    
    func isPurchased() -> Bool {
        return UserDefaults.standard.bool(forKey: id)
    }
    
    
    fileprivate func recordTransaction(transaction: SKPaymentTransaction) {
        if transaction.payment.productIdentifier == self.id, let appStoreReceipt = Bundle.main.appStoreReceiptURL {
            if let data = try? Data(contentsOf: appStoreReceipt) {
                UserDefaults.standard.set(data, forKey: self.id + "receipt")
            }
        }
    }
    
    fileprivate func provideContent(id: String) {
        UserDefaults.standard.set(true, forKey: id)
    }
    
    fileprivate func finishTransaction(transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    
    fileprivate func completeTransaction(transaction: SKPaymentTransaction) {
        recordTransaction(transaction: transaction)
        provideContent(id: transaction.payment.productIdentifier)
        finishTransaction(transaction: transaction)
        
        completion?()
    }
    
    fileprivate func restoreTransaction(transaction: SKPaymentTransaction) {
        if let originalTransaction = transaction.original {
            completeTransaction(transaction: originalTransaction)
            
            completion?()
        }
    }
    
    fileprivate func failedTransaction(transaction: SKPaymentTransaction) {
        finishTransaction(transaction: transaction)
        
        completion?()
    }
    
}


extension InAppPurchase: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products.first {
            self.product = product
        }
        
        self.isLoading = false
        productDataObtained?()
    }
    
}

extension InAppPurchase: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { transaction in
            switch transaction.transactionState {
            case .purchased:
                isLoading = false
                completeTransaction(transaction: transaction)
            case .purchasing: break
            case .failed:
                isLoading = false
                failedTransaction(transaction: transaction)
            case .restored:
                isLoading = false
                restoreTransaction(transaction: transaction)
            case .deferred:
                isLoading = false
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        restoreCompletion?()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        restoreCompletion?()
    }
    
}
