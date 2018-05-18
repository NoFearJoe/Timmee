//
//  HiddingParameterView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 17.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit


class HiddingParameterView: UIView {

    @IBOutlet private var separator: UIView?
    @IBOutlet private var verticalConstraints: [NSLayoutConstraint]?
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    var originalHeight: CGFloat = 40
    
    override var isHidden: Bool {
        didSet {
            heightConstraint?.constant = isHidden ? 0 : originalHeight
            separator?.alpha = isHidden ? 0 : 1
            verticalConstraints?.forEach { constraint in
                constraint.constant = isHidden ? 0 : 8
            }
        }
    }

}
