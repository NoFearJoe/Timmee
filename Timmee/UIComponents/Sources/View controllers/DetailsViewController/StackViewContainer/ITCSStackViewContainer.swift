//
//  ITCSStackViewContainer.swift
//  TinkoffUIKit
//
//  Created by n.sidiropulo on 29/11/16.
//  Copyright © 2016 АО «Тинькофф Банк», лицензия ЦБ РФ № 2673. All rights reserved.
//

import UIKit

/// Container for stack view
public protocol ITCSStackViewContainer {
    
    func addView(_ view: UIView)
    func removeView(_ view: UIView)
    func insertView(_ view: UIView, at index: Int)
    func replaceView(_ oldView: UIView, with newView: UIView)
    func removeAllViews()
    
    func placeController(_ controller: UIViewController, isHidden: Bool)
    
    var numberOfViews: Int { get }
}

public extension ITCSStackViewContainer {
    
    func placeController(_ controller: UIViewController) {
        placeController(controller, isHidden: false)
    }
}
