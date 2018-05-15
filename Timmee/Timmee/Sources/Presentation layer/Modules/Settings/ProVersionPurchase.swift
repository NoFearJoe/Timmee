//
//  ProVersionPurchase.swift
//  Timmee
//
//  Created by i.kharabet on 15.05.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import StoreKit

final class ProVersionPurchase: NSObject {
    
    var product: SKProduct?
    
}

extension ProVersionPurchase: SKRequestDelegate {
    
    func requestDidFinish(_ request: SKRequest) {
        
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        
    }
    
}

extension ProVersionPurchase: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
    }
    
}
