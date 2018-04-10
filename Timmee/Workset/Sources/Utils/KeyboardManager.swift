//
//  KeyboardManager.swift
//  Timmee
//
//  Created by Ilya Kharabet on 01.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

public final class KeyboardManager {
    
    public typealias KeyboardEventClosure = (_ keyboardFrame: CGRect, _ duration: TimeInterval) -> ()
    
    public var keyboardWillAppear: KeyboardEventClosure?
    public var keyboardWillDisappear: KeyboardEventClosure?
    public var keyboardFrameDidChange: KeyboardEventClosure?
    
    
    public init() {
        subscribeToKeyboardEvents()
    }
    
    public func unsubscribe() {
        keyboardWillAppear = nil
        keyboardWillDisappear = nil
        keyboardFrameDidChange = nil
    }
    
    
    private func subscribeToKeyboardEvents() {
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
    
    
    @objc private func keyboardWillAppear(_ notification: Notification) {
        if let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            
            keyboardWillAppear?(keyboardFrame, animationDuration)
        }
    }
    
    @objc private func keyboardWillDisappear(_ notification: Notification) {
        if let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            
            keyboardWillDisappear?(keyboardFrame, animationDuration)
        }
    }
    
    @objc private func keyboardFrameDidChange(_ notification: Notification) {
        if let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            
            keyboardFrameDidChange?(keyboardFrame, animationDuration)
        }
    }
    
}

