//
//  BaseViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 20.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return AppThemeType.current == .dark ? .lightContent : .default
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAppearance()
    }
    
    func setupAppearance() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = AppThemeType.current == .dark ? .black : .default
        navigationController?.navigationBar.barTintColor = AppTheme.current.colors.foregroundColor
        navigationController?.navigationBar.tintColor = AppTheme.current.colors.activeElementColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: AppTheme.current.colors.activeElementColor]
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: AppTheme.current.colors.activeElementColor]
        }
        
        view.backgroundColor = AppTheme.current.colors.middlegroundColor
    }
    
}
