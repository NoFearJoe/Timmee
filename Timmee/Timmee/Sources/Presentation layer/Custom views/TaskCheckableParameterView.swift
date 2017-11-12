//
//  TaskCheckableParameterView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 17.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class TaskCheckableParameterView: HiddingParameterView {

    @IBOutlet fileprivate weak var checkBox: CheckBox!
    @IBOutlet fileprivate weak var titleView: UILabel!
    
    var didChangeCkeckedState: ((Bool) -> Void)?
    
    var isChecked: Bool = false {
        didSet {
            setChecked(isChecked)
            didChangeCkeckedState?(isChecked)
        }
    }
    
    fileprivate let checkedTitleColor = AppTheme.current.tintColor
    fileprivate let uncheckedTitleColor = AppTheme.current.secondaryTintColor
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTapGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addTapGestureRecognizer()
    }
    
    fileprivate func setChecked(_ isChecked: Bool) {
        checkBox.isChecked = isChecked
        UIView.animate(withDuration: 0.2) { 
            self.titleView.textColor = isChecked ? self.checkedTitleColor : self.uncheckedTitleColor
        }
    }
    
    fileprivate func addTapGestureRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(TaskCheckableParameterView.onTap))
        addGestureRecognizer(recognizer)
    }
    
    @objc fileprivate func onTap() {
        isChecked = !isChecked
    }

}
