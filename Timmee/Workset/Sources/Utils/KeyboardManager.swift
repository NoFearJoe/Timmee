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
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(KeyboardManager.keyboardWillDisappear(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(KeyboardManager.keyboardFrameDidChange(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    
    @objc private func keyboardWillAppear(_ notification: Notification) {
        if let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            
            keyboardWillAppear?(keyboardFrame, animationDuration)
        }
    }
    
    @objc private func keyboardWillDisappear(_ notification: Notification) {
        if let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            
            keyboardWillDisappear?(keyboardFrame, animationDuration)
        }
    }
    
    @objc private func keyboardFrameDidChange(_ notification: Notification) {
        if let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            
            keyboardFrameDidChange?(keyboardFrame, animationDuration)
        }
    }
    
}

