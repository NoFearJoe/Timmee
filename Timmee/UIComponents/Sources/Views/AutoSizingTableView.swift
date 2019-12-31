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
        var size = contentSize
        
        size.width += contentInset.left + contentInset.right
        size.height += contentInset.top + contentInset.bottom
        
        return size
    }
    
}

public final class AutosizingReorderableTableView: ReorderableTableView {
    
    public override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        var size = contentSize
        
        size.width += contentInset.left + contentInset.right
        size.height += contentInset.top + contentInset.bottom
        
        return size
    }
    
}
