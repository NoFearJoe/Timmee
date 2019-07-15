//
//  AboutAppViewController.swift
//  Timmee
//
//  Created by i.kharabet on 29.12.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class AboutAppViewController: UIViewController {
    
    @IBOutlet private var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "about_app".localized
        
        textView.text = "about_app_text".localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = AppTheme.current.backgroundColor
        
        textView.textColor = AppTheme.current.backgroundTintColor
    }
    
}
