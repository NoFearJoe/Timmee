//
//  DetailsFullPlaceholderDefault.swift
//  MobileBank
//
//  Created by a.y.zverev on 30.01.2018.
//  Copyright © 2018 АО «Тинькофф Банк», лицензия ЦБ РФ № 2673. All rights reserved.
//

import UIKit

public class DetailsFullPlaceholderDefault: UIView, AnimatableView {
    
    public func startAnimating() {}
    public func stopAnimating() {}
    public func clearAnimations() {}
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var logoView: UIView!
    @IBOutlet weak var logoBgView: UIView!
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
//        logoView.tcs.makeRounded()
//        logoBgView.tcs.makeRounded()
        
        self.subviews.forEach { $0.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.97, alpha: 1.0) }
        logoBgView.backgroundColor = .white
    }
}
