//
//  TaskParameterView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 17.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

class TaskParameterView: HiddingParameterView {

    @IBOutlet fileprivate var iconView: UIImageView!
    @IBOutlet fileprivate var titleView: UILabel!
    @IBOutlet fileprivate var clearButton: UIButton! {
        didSet {
            clearButton.tintColor = AppTheme.current.thirdlyTintColor
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
    
    var canClear: Bool = true {
        didSet {
            clearButton.isHidden = !(canClear && isFilled)
        }
    }
    
    fileprivate let filledIconColor = AppTheme.current.blueColor
    var filledTitleColor = AppTheme.current.tintColor
    
    fileprivate let notFilledIconColor = AppTheme.current.thirdlyTintColor
    fileprivate let notFilledTitleColor = AppTheme.current.secondaryTintColor
    
    func setFilled(_ isFilled: Bool) {
        UIView.animate(withDuration: 0.2) { 
            self.iconView.tintColor = isFilled ? self.filledIconColor : self.notFilledIconColor
            self.updateTitleColor()
            
            self.clearButton.isHidden = !(self.canClear && isFilled)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTapGestureRecognizer(to: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addTapGestureRecognizer(to: self)
    }
    
    func updateTitleColor() {
        titleView?.textColor = isFilled ? self.filledTitleColor : self.notFilledTitleColor
    }
    
    private func addTapGestureRecognizer(to view: UIView) {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        recognizer.delegate = self
        view.addGestureRecognizer(recognizer)
    }
    
    @objc fileprivate func onTap() {
        didTouchedUp?()
    }
    
    @IBAction fileprivate func onClear() {
        didClear?()
    }

}

extension TaskParameterView: UIGestureRecognizerDelegate {}

final class TaskComplexParameterView: TaskParameterView {
    
    @IBOutlet fileprivate var subtitleLabel: UILabel!
    
    fileprivate let filledSubtitleColor = AppTheme.current.secondaryTintColor
    fileprivate let notFilledSubtitleColor = AppTheme.current.thirdlyTintColor
    
    var subtitle: String? {
        get { return subtitleLabel.text }
        set { subtitleLabel.text = newValue }
    }
    
    override func setFilled(_ isFilled: Bool) {
        super.setFilled(isFilled)
        
        UIView.animate(withDuration: 0.2) {
            self.subtitleLabel.textColor = isFilled ? self.filledSubtitleColor : self.notFilledSubtitleColor
        }
    }
    
}
