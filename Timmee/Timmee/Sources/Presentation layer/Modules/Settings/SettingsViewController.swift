//
//  SettingsViewController.swift
//  test_label
//
//  Created by i.kharabet on 20.10.17.
//  Copyright © 2017 i.kharabet. All rights reserved.
//

import UIKit

enum SettingsSection {
    case general
    case security
    case about
    
    var title: String {
        switch self {
        case .general: return "general_section".localized
        case .security: return "security_section".localized
        case .about: return "about_section".localized
        }
    }
}

struct SettingsItem {
    
    enum Style {
        case title
        case titleWithSubtitle
        case titleWithSwitch
        case detailsTitle
        case detailsSubtitle
    }
    
    var title: String
    var subtitle: String?
    var icon: UIImage
    var isOn: Bool
    var isDetailed: Bool
    
    var style: Style = .title
    
    var action: (() -> Void)?
    
}

final class SettingsViewController: UIViewController {
    
    @IBOutlet fileprivate var tableView: UITableView!
    @IBOutlet fileprivate var loadingView: LoadingView!
    
    var settingsItems: [(SettingsSection, [SettingsItem])] = []
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        InAppPurchase.abstract.loadStore()
        
        settingsItems = makeSettingsItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAppearance()
        reloadSettings()
    }
    
    fileprivate func reloadSettings() {
        settingsItems = makeSettingsItems()
        tableView.reloadData()
    }
    
}

extension SettingsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingsItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsItems[section].1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = settingsItems[indexPath.section].1[indexPath.row]
        
        let cellIdentifier: String
        switch item.style {
        case .title: cellIdentifier = SettingsCellWithTitle.identifier
        case .titleWithSubtitle: cellIdentifier = SettingsCellWithTitleAndSubtitle.identifier
        case .titleWithSwitch: cellIdentifier = SettingsCellWithTitleAndSwitch.identifier
        case .detailsTitle: cellIdentifier = SettingsDetailsCellWithTitle.identifier
        case .detailsSubtitle: cellIdentifier = SettingsDetailsCellWithTitleAndSubtitle.identifier
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BaseSettingsCell
        
        cell.setDisplayItem(item)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingsItems[section].0.title
    }
    
}

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = settingsItems[indexPath.section].1[indexPath.row]
        
        switch item.style {
        case .detailsTitle, .detailsSubtitle, .titleWithSubtitle: item.action?()
        default: break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

fileprivate extension SettingsViewController {
    
    func makeSettingsItems() -> [(SettingsSection, [SettingsItem])] {
        return [
            (.general, makeGeneralSectionItems()),
            (.security, makeSecuritySectionItems()),
            (.about, makeAboutSectionItems())
        ]
    }
    
    func makeGeneralSectionItems() -> [SettingsItem] {
        var generalSectionItems: [SettingsItem] = []
        
        let currentListSorting = ListSorting(value: UserProperty.listSorting.int())
        let listSortingAction = { [unowned self] in
            UserProperty.listSorting.setInt(currentListSorting.next.rawValue)
            self.reloadSettings()
        }
        let listSortingItem = SettingsItem(title: "list_sorting".localized,
                                           subtitle: currentListSorting.title,
                                           icon: #imageLiteral(resourceName: "defaultListIcon"),
                                           isOn: false,
                                           isDetailed: false,
                                           style: .titleWithSubtitle,
                                           action: listSortingAction)
        
        generalSectionItems.append(listSortingItem)
        
//        let currentTheme = AppTheme.current
//        let themeAction = { [unowned self] in
//            UserProperty.appTheme.setInt(currentTheme.next.code)
//            // Redraw???
//            self.reloadSettings()
//        }
//        let themeItem = SettingsItem(title: "theme".localized,
//                                     subtitle: currentTheme.title,
//                                     icon: #imageLiteral(resourceName: "artListIcon"),
//                                     isOn: false,
//                                     isDetailed: false,
//                                     style: .titleWithSubtitle,
//                                     action: themeAction)
        
//        if UserProperty.inApp(InAppPurchaseItem.darkTheme.id).bool() {
//            generalSectionItems.append(themeItem)
//        }
        
        return generalSectionItems
    }
    
    func makeSecuritySectionItems() -> [SettingsItem] {
        var securitySectionItems: [SettingsItem] = []
        
        let isPinCodeSet = UserProperty.pinCode.value() != nil
        let pinCodeAction = { [unowned self] in
            let viewController = ViewControllersFactory.pinCreation
            viewController.isRemovePinCodeButtonVisible = isPinCodeSet
            viewController.onComplete = { [unowned self] in
                self.navigationController?.popToRootViewController(animated: true)
            }
            
            if isPinCodeSet {
                self.showConfirmationAlert(title: "attention".localized, message: "change_pin_code".localized, onConfirm: { [unowned self] in
                    self.navigationController?.pushViewController(viewController, animated: true)
                })
            } else {
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
        let pinCodeSubtitle = isPinCodeSet ? "is_on".localized : "is_off".localized
        let pinCodeItem = SettingsItem(title: "pin_code_protection".localized,
                                       subtitle: pinCodeSubtitle,
                                       icon: #imageLiteral(resourceName: "settings"),
                                       isOn: false,
                                       isDetailed: true,
                                       style: .detailsSubtitle,
                                       action: pinCodeAction)
        
        securitySectionItems.append(pinCodeItem)
        
        let biometricsType = UIDevice.current.biometricsType
        let isBiometricsEnabled = UserProperty.biometricsAuthenticationEnabled.bool()
        let biometricsAction = {
            let value = !UserProperty.biometricsAuthenticationEnabled.bool()
            UserProperty.biometricsAuthenticationEnabled.setBool(value)
        }
        let biometricsItem = SettingsItem(title: biometricsType.localizedTitle,
                                          subtitle: nil,
                                          icon: biometricsType.smallImage,
                                          isOn: isBiometricsEnabled,
                                          isDetailed: false,
                                          style: .titleWithSwitch,
                                          action: biometricsAction)
        
        if isPinCodeSet, biometricsType != .none {
            securitySectionItems.append(biometricsItem)
        }
        
        return securitySectionItems
    }
    
    func makeAboutSectionItems() -> [SettingsItem] {
        var aboutSectionItems: [SettingsItem] = []
        
        let isAppRated = UserProperty.isAppRated.bool()
        let rateAction = {
            if let url = URL(string: "itms-apps://itunes.apple.com/app/id") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.openURL(url)
                }
            }
            UserProperty.isAppRated.setBool(true)
        }
        let rateItem = SettingsItem(title: "rate".localized,
                                    subtitle: nil,
                                    icon: #imageLiteral(resourceName: "starListIcon"),
                                    isOn: false,
                                    isDetailed: true,
                                    style: .detailsTitle,
                                    action: rateAction)
        
        if !isAppRated {
            aboutSectionItems.append(rateItem)
        }
        
        let licenseAction = { [unowned self] in
            let viewController = UIViewController() // TODO
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        let licenseItem = SettingsItem(title: "license".localized,
                                       subtitle: nil,
                                       icon: #imageLiteral(resourceName: "chatListIcon"),
                                       isOn: false,
                                       isDetailed: true,
                                       style: .detailsTitle,
                                       action: licenseAction)
        
        aboutSectionItems.append(licenseItem)
        
        let restoreAction = { [unowned self] in
            self.setLoadingVisible(true)
            InAppPurchase.abstract.restore { [weak self] in
                self?.setLoadingVisible(false)
                // TODO: Reload in app carousel
            }
        }
        let restorePurchasesItem = SettingsItem(title: "restore_purchases".localized,
                                                subtitle: nil,
                                                icon: #imageLiteral(resourceName: "repeat"),
                                                isOn: false,
                                                isDetailed: true,
                                                style: .detailsTitle,
                                                action: restoreAction)
        
        aboutSectionItems.append(restorePurchasesItem)
        
        return aboutSectionItems
    }
    
}

fileprivate extension SettingsViewController {
    
    func setLoadingVisible(_ isVisible: Bool) {
        view.isUserInteractionEnabled = !isVisible
        loadingView.isHidden = !isVisible
    }
    
}

fileprivate extension SettingsViewController {

    func showConfirmationAlert(title: String, message: String, onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "yes".localized, style: .default, handler: { action in
            onConfirm()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
}

fileprivate extension SettingsViewController {
    
    func setupAppearance() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.barTintColor = AppTheme.current.backgroundColor
        navigationController?.navigationBar.tintColor = AppTheme.current.backgroundTintColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: AppTheme.current.backgroundTintColor]
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.largeTitleTextAttributes = [NSForegroundColorAttributeName: AppTheme.current.backgroundTintColor]
        }
        
        view.backgroundColor = AppTheme.current.middlegroundColor
        tableView.backgroundColor = AppTheme.current.middlegroundColor
    }
    
}
