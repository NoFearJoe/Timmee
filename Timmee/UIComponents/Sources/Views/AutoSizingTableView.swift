//
//  AutoSizingTableView.swift
//  UIComponents
//
//  Created by i.kharabet on 29/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

open class AutoSizingTableView: UITableView {
    
    open override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    open override var intrinsicContentSize: CGSize {
        return contentSize
    }
    
}
