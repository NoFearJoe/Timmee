//
//  ChartsViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 19.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class ChartsViewController: UIViewController {
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "my_progress".localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAppearance()
    }
    
}

private extension ChartsViewController {
    
    func setupAppearance() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.barTintColor = AppTheme.current.colors.foregroundColor
        navigationController?.navigationBar.tintColor = AppTheme.current.colors.activeElementColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: AppTheme.current.colors.activeElementColor]
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: AppTheme.current.colors.activeElementColor]
        }
        
        view.backgroundColor = AppTheme.current.colors.middlegroundColor
    }
    
}
