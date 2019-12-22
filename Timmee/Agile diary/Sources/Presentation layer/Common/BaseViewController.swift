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
        if #available(iOS 13.0, *) {
            return AppThemeType.current == .dark ? .lightContent : .darkContent
        } else {
            return AppThemeType.current == .dark ? .lightContent : .default
        }
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onThemeChanged),
                                               name: AppTheme.themeChanged,
                                               object: nil)
    }
    
    @objc private func onBecomeActive() {
        refresh()
    }
    
    @objc private func onThemeChanged() {
        setupAppearance()
    }
    
    // MARK: - Screen
    
    var isVisible: Bool {
        return self.isViewLoaded && self.view.window != nil
    }
    
    func prepare() {}
    
    func setupAppearance() {
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.backgroundColor = AppTheme.current.colors.foregroundColor
            navBarAppearance.titleTextAttributes = [.foregroundColor: AppTheme.current.colors.activeElementColor]
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: AppTheme.current.colors.activeElementColor]
            
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.compactAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
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
