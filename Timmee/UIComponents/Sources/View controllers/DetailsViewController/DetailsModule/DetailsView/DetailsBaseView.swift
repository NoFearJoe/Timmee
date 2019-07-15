//
//  DetailsBaseView.swift
//  MobileBank
//
//  Created by g.novik on 13.10.2017.
//  Copyright © 2017 АО «Тинькофф Банк», лицензия ЦБ РФ № 2673. All rights reserved.
//

import UIKit

public class DetailsBaseView: UIView {
    
    weak public var headerView: UIView?
    weak public var stackViewContainer: UIScrollView?
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard
            let headerView = headerView,
            let stackViewContainer = stackViewContainer
            else {
                return super.point(inside: point, with: event)
        }
        
        if headerView.point(inside: convert(point,
                                            to: headerView), with: event) {
            headerView.addGestureRecognizer(stackViewContainer.panGestureRecognizer)
        } else if stackViewContainer.point(inside: convert(point,
                                                           to: stackViewContainer), with: event) {
            stackViewContainer.addGestureRecognizer(stackViewContainer.panGestureRecognizer)
        }
        
        return super.point(inside: point, with: event)
    }
}
