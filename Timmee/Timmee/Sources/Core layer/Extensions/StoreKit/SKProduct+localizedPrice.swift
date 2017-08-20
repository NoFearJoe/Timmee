//
//  SKProduct+localizedPrice.swift
//  Alias
//
//  Created by Ilya Kharabet on 13.01.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foundation.NumberFormatter
import class StoreKit.SKProduct

extension SKProduct {

    func localizedPrice() -> String {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        
        let formattedString = formatter.string(from: self.price)
        return formattedString ?? ""
    }

}
