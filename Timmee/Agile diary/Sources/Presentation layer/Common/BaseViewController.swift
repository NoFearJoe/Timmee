//
//  BaseViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 20.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

public protocol Screen: class {
    var isVisible: Bool { get }
    
    func prepare()
    func setupAppearance()
    func refresh()
}

class BaseViewController: UIViewController, Screen {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return AppThemeType.current == .dark ? .lightContent : .default
    }
    
    final override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToAppBecomeActive()
        prepare()
    }
    
    final override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAppearance()
        refresh()
    }
    
    private func subscribeToAppBecomeActive() {
        NotificationCenter.default.addObserver(self, selector: #selector(onBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc private func onBecomeActive() {
        refresh()
    }
    
    // MARK: - Screen
    
    var isVisible: Bool {
        return self.isViewLoaded && self.view.window != nil
    }
    
    func prepare() {}
    
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
    
    func refresh() {}
    
}
