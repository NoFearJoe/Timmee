//
//  TaskParameterView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 17.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

class TaskParameterView: HiddingParameterView {

    @IBOutlet private var iconView: UIImageView!
    @IBOutlet private var titleView: UILabel!
    @IBOutlet private var clearButton: UIButton! {
        didSet {
            clearButton.tintColor = AppTheme.current.thirdlyTintColor
        }
    }
    
    var didChangeFilledState: ((Bool) -> Void)?
    var didTouchedUp: (() -> Void)?
    var didClear: (() -> Void)?
    
    var isFilled: Bool = false {
        didSet {
            setFilled(isFilled, animated: false)
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
    
    private let filledIconColor = AppTheme.current.blueColor
    var filledTitleColor = AppTheme.current.tintColor
    
    private let notFilledIconColor = AppTheme.current.thirdlyTintColor
    private let notFilledTitleColor = AppTheme.current.secondaryTintColor
    
    func setFilled(_ isFilled: Bool, animated: Bool) {
        let action = {
            self.iconView.tintColor = isFilled ? self.filledIconColor : self.notFilledIconColor
            self.updateTitleColor()
            
            self.clearButton.isHidden = !(self.canClear && isFilled)
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: action)
        } else {
            action()
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
    
    func setup(withParameter parameter: RegularitySettingsViewController.Parameter) {
        switch parameter {
        case .timeTemplate: iconView.image = UIImage(named: "time_template")
        case .dueDateTime: iconView.image = UIImage(named: "clock")
        case .dueDate: iconView.image = UIImage(named: "clock")
        case .dueTime: iconView.image = UIImage(named: "clock")
        case .startDate: iconView.image = UIImage(named: "clock") // TODO
        case .endDate: iconView.image = UIImage(named: "finish")
        case .notification: iconView.image = UIImage(named: "alarm")
        case .repeating: iconView.image = UIImage(named: "repeat")
        }
    }
    
    func updateTitleColor() {
        titleView?.textColor = isFilled ? self.filledTitleColor : self.notFilledTitleColor
    }
    
    private func addTapGestureRecognizer(to view: UIView) {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        recognizer.delegate = self
        view.addGestureRecognizer(recognizer)
    }
    
    @objc private func onTap() {
        didTouchedUp?()
    }
    
    @IBAction private func onClear() {
        didClear?()
    }

}

extension TaskParameterView: UIGestureRecognizerDelegate {}

final class TaskComplexParameterView: TaskParameterView {
    
    @IBOutlet private var subtitleLabel: UILabel!
    
    private let filledSubtitleColor = AppTheme.current.secondaryTintColor
    private let notFilledSubtitleColor = AppTheme.current.thirdlyTintColor
    
    var subtitle: String? {
        get { return subtitleLabel.text }
        set { subtitleLabel.text = newValue }
    }
    
    override func setFilled(_ isFilled: Bool, animated: Bool) {
        super.setFilled(isFilled, animated: animated)
        
        let action = {
            self.subtitleLabel.textColor = isFilled ? self.filledSubtitleColor : self.notFilledSubtitleColor
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: action)
        } else {
            action()
        }
    }
    
}
