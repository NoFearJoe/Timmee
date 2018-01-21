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
    
    @IBOutlet fileprivate weak var iconView: UIImageView!
    
    var isPicked: Bool = false {
        didSet {
            iconView.image = isPicked ? #imageLiteral(resourceName: "important_active_big") : #imageLiteral(resourceName: "important_inactive_big")
        }
    }
    
    var onPick: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = true
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(recognizer)
    }
    
    @objc fileprivate func onTap() {
        isPicked = !isPicked
        onPick?(isPicked)
    }
    
}
