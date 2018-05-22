//
//  ProVersionPurchase.swift
//  Timmee
//
//  Created by i.kharabet on 15.05.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import StoreKit

final class ProVersionPurchase: NSObject {
    
    static let shared = ProVersionPurchase()
    
    var product: SKProduct?
    var request: SKProductsRequest?
    
    let id = "com.mesterra.memori.pro"
    
    var isLoading = false
    
    private var completion: (() -> Void)?
    private var productDataObtained: (() -> Void)?
    private var restoreCompletion: ((Bool) -> Void)?
    
    func loadStore() {
        SKPaymentQueue.default().add(self)
    }
    
    func requestData(completion: @escaping () -> Void) {
        if product != nil {
            completion()
        } else {
            self.productDataObtained = completion
            
            let idSet = Set(arrayLiteral: id)
            request = SKProductsRequest(productIdentifiers: idSet)
            request?.delegate = self
            request?.start()
            
            isLoading = true
        }
    }
    
    
    func canPurchase() -> Bool {
        return SKPaymentQueue.canMakePayments() && product != nil
    }
    
    func purchase(completion: @escaping () -> Void) {
        self.completion = completion
        if let product = self.product, canPurchase() {
            isLoading = true
            let payment = SKPayment(product: product)
            guard payment.quantity > 0 else { return }
            SKPaymentQueue.default().add(payment)
        }
    }
    
    func restore(completion: @escaping (Bool) -> Void) {
        self.restoreCompletion = completion
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    
    func isPurchased() -> Bool {
        return UserDefaults.standard.bool(forKey: id)
    }
    
    
    private func recordTransaction(transaction: SKPaymentTransaction) {
        if transaction.payment.productIdentifier == self.id, let appStoreReceipt = Bundle.main.appStoreReceiptURL {
            if let data = try? Data(contentsOf: appStoreReceipt) {
                UserDefaults.standard.set(data, forKey: self.id + "receipt")
            }
        }
    }
    
    private func provideContent(id: String) {
        UserDefaults.standard.set(true, forKey: id)
    }
    
    private func finishTransaction(transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    
    private func completeTransaction(transaction: SKPaymentTransaction) {
        recordTransaction(transaction: transaction)
        provideContent(id: transaction.payment.productIdentifier)
        finishTransaction(transaction: transaction)
        
        completion?()
    }
    
    private func restoreTransaction(transaction: SKPaymentTransaction) {
        if let originalTransaction = transaction.original {
            completeTransaction(transaction: originalTransaction)
            completion?()
        }
    }
    
    private func failedTransaction(transaction: SKPaymentTransaction) {
        finishTransaction(transaction: transaction)
        completion?()
    }
    
}


extension ProVersionPurchase: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let product = response.products.first {
            self.product = product
        }
        
        self.isLoading = false
        productDataObtained?()
    }
    
}

extension ProVersionPurchase: SKPaymentTransactionObserver {
    
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
        restoreCompletion?(true)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        restoreCompletion?(false)
    }
    
}
