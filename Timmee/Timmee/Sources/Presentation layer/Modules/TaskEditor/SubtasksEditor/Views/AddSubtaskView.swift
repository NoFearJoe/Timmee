//
//  AddSubtaskView.swift
//  Timmee
//
//  Created by i.kharabet on 13.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class AddSubtaskView: UIView {
    
    @IBOutlet fileprivate var decorationView: UIImageView! {
        didSet {
            decorationView.tintColor = AppTheme.current.secondaryTintColor
        }
    }
    @IBOutlet fileprivate var titleField: UITextField! {
        didSet {
            titleField.delegate = self
            titleField.textColor = AppTheme.current.tintColor
        }
    }
    
    var title: String {
        get { return titleField.text ?? "" }
        set { titleField.text = newValue }
    }
    
    override var isFirstResponder: Bool {
        return titleField.isFirstResponder
    }
    
    var didEndEditing: ((String) -> Void)?
    
}

extension AddSubtaskView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didEndEditing?(title)
        textField.text = nil
        return true
    }
    
}
