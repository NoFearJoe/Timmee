//
//  TaskImportancyPicker.swift
//  Timmee
//
//  Created by Илья Харабет on 20.01.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import Foundation
import class UIKit.UIView
import class UIKit.UIImageView
import class UIKit.UITapGestureRecognizer

final class TaskImportancyPicker: UIView {
    
    @IBOutlet private weak var iconView: UIImageView!
    
    var isPicked: Bool = false {
        didSet {
            iconView.tintColor = isPicked ? AppTheme.current.redColor : AppTheme.current.thirdlyTintColor
        }
    }
    
    var changeStateAutomatically = true
    
    var onPick: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = true
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(recognizer)
        
        isPicked = false
    }
    
    @objc private func onTap() {
        if changeStateAutomatically {
            isPicked = !isPicked
        }
        onPick?(isPicked)
    }
    
}
