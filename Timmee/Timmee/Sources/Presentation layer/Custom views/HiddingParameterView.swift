//
//  HiddingParameterView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 17.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit


class HiddingParameterView: UIView {

    @IBOutlet fileprivate weak var heightConstraint: NSLayoutConstraint!
    fileprivate var originalHeight: CGFloat = 40
    
    override var isHidden: Bool {
        didSet {
            heightConstraint?.constant = isHidden ? 0 : originalHeight
        }
    }

}
