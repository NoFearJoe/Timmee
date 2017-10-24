//
//  TaskParameterView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 17.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class TaskParameterView: HiddingParameterView {

    @IBOutlet fileprivate weak var iconView: UIImageView!
    @IBOutlet fileprivate weak var titleView: UILabel!
    @IBOutlet fileprivate weak var clearButton: UIButton! {
        didSet {
            clearButton.tintColor = AppTheme.current.scheme.tintColor.withAlphaComponent(0.5)
        }
    }
    
    var didChangeFilledState: ((Bool) -> Void)?
    var didTouchedUp: (() -> Void)?
    var didClear: (() -> Void)?
    
    var isFilled: Bool = false {
        didSet {
            setFilled(isFilled)
            didChangeFilledState?(isFilled)
        }
    }
    
    var text: String? {
        get { return titleView.text }
        set { titleView.text = newValue }
    }
    
    fileprivate let filledIconColor = AppTheme.current.scheme.blueColor
    fileprivate let filledTitleColor = AppTheme.current.scheme.tintColor
    
    fileprivate let notFilledIconColor = AppTheme.current.scheme.secondaryTintColor
    fileprivate let notFilledTitleColor = AppTheme.current.scheme.secondaryTintColor
    
    fileprivate func setFilled(_ isFilled: Bool) {
        UIView.animate(withDuration: 0.2) { 
            self.iconView.tintColor = isFilled ? self.filledIconColor : self.notFilledIconColor
            self.titleView.textColor = isFilled ? self.filledTitleColor : self.notFilledTitleColor
            
            self.clearButton.isHidden = !isFilled
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTapGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addTapGestureRecognizer()
    }
    
    fileprivate func addTapGestureRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(recognizer)
    }
    
    @objc fileprivate func onTap() {
        didTouchedUp?()
    }
    
    @IBAction fileprivate func onClear() {
        didClear?()
    }

}
