//
//  NumPadButton.swift
//  Test
//
//  Created by i.kharabet on 18.08.17.
//  Copyright © 2017 i.kharabet. All rights reserved.
//

import UIKit

public final class NumPadButton: UIButton {

    @IBInspectable public dynamic var borderWidth: CGFloat = 1
    @IBInspectable public dynamic var borderColor: UIColor = .black
    
    public var number: Int? {
        get {
            guard let title = title(for: .normal) else { return nil }
            return Int(title)
        }
        set {
            guard let number = newValue else { return }
            setTitle(String(describing: number), for: .normal)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureBorder()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureBorder()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.size.width * 0.5
    }
    
    fileprivate func configureBorder() {
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
    }

}
