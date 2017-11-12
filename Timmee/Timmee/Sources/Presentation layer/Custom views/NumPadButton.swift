//
//  NumPadButton.swift
//  Test
//
//  Created by i.kharabet on 18.08.17.
//  Copyright © 2017 i.kharabet. All rights reserved.
//

import UIKit

final class NumPadButton: UIButton {

    @IBInspectable dynamic var borderWidth: CGFloat = 1
    @IBInspectable dynamic var borderColor: UIColor = .black
    
    var number: Int? {
        get {
            guard let title = title(for: .normal) else { return nil }
            return Int(title)
        }
        set {
            guard let number = newValue else { return }
            setTitle(String(describing: number), for: .normal)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureBorder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureBorder()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.size.width * 0.5
    }
    
    fileprivate func configureBorder() {
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
    }

}
