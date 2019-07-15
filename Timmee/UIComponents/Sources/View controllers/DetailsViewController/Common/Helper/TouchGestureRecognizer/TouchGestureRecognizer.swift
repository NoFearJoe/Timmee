//
//  TouchGestureRecognizer.swift
//  MobileBank
//
//  Created by a.shilkin on 23.08.17.
//  Copyright © 2017 АО «Тинькофф Банк», лицензия ЦБ РФ № 2673. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

/// GestureRecognizer, который обрабатывает все нажатия
class TouchGestureRecognizer: UIGestureRecognizer {
    
    override func canPrevent(_ preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        self.state = .began
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        guard let view = view, let point = Array(touches).last?.location(in: view) else {
            return
        }
        
        if view.bounds.contains(point) {
            self.state = .changed
        } else {
            self.state = .cancelled
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        self.state = .ended
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        self.state = .cancelled
    }
}
