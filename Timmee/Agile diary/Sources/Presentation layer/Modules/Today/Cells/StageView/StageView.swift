//
//  StageView.swift
//  Agile diary
//
//  Created by i.kharabet on 11.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class StageView: UIView {
    
    var onChangeCheckedState: ((Bool) -> Void)?
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var checkbox: Checkbox! {
        didSet {
            checkbox.didChangeCkeckedState = { [unowned self] isChecked in
                
            }
        }
    }
    
}
