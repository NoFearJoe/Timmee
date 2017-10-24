//
//  KeyboardManager.swift
//  Timmee
//
//  Created by Ilya Kharabet on 01.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class KeyboardManager {
    
    typealias KeyboardEventClosure = (_ keyboardFrame: CGRect, _ duration: TimeInterval) -> ()
    
    var keyboardWillAppear: KeyboardEventClosure?
    var keyboardWillDisappear: KeyboardEventClosure?
    var keyboardFrameDidChange: KeyboardEventClosure?
    
    
    init() {
        subscribeToKeyboardEvents()
    }
    
    
    fileprivate func subscribeToKeyboardEvents() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(KeyboardManager.keyboardWillAppear(_:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(KeyboardManager.keyboardWillDisappear(_:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(KeyboardManager.keyboardFrameDidChange(_:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
    }
    
    
    @objc fileprivate func keyboardWillAppear(_ notification: Notification) {
        if let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            
            keyboardWillAppear?(keyboardFrame, animationDuration)
        }
    }
    
    @objc fileprivate func keyboardWillDisappear(_ notification: Notification) {
        if let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            
            keyboardWillDisappear?(keyboardFrame, animationDuration)
        }
    }
    
    @objc fileprivate func keyboardFrameDidChange(_ notification: Notification) {
        if let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            
            keyboardFrameDidChange?(keyboardFrame, animationDuration)
        }
    }
    
}

