//
//  SettingsViewController.swift
//  Agile diary
//
//  Created by Илья Харабет on 18.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import enum MessageUI.MFMailComposeResult
import class MessageUI.MFMailComposeViewController
import protocol MessageUI.MFMailComposeViewControllerDelegate

enum SettingsSection {
    case general
    case proVersion
    case security
    case about
    
    var title: String {
        switch self {
        case .general: return "general_section".localized
        case .proVersion: return "pro_version_section".localized
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
        case proVersion
        case proVersionFeatures
        case backgroundImage
    }
    
    var title: String
    var subtitle: String?
    var icon: UIImage
    var isOn: Bool
    var isDetailed: Bool
    let isSelectable: Bool
    
    var style: Style = .title
    
    var action: (() -> Void)?
    var helpAction: (() -> Void)? = nil
    
    init(title: String,
         subtitle: String? = nil,
         icon: UIImage,
         isOn: Bool = false,
         isDetailed: Bool = false,
         isSelectable: Bool = true,
         style: Style = .title,
         action: (() -> Void)?) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.isOn = isOn
        self.isDetailed = isDetailed
        self.isSelectable = isSelectable
        self.style = style
        self.action = action
    }
    
}

final class SettingsViewController: BaseViewController {
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var loadingView: LoadingView!
    
    var settingsItems: [(SettingsSection, [SettingsItem])] = []
    
    private var areProVersionFeaturesShown = false
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "settings".localized
        
        settingsItems = makeSettingsItems()
        
        ProVersionPurchase.shared.loadStore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAppearance()
        reloadSettings()
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        tableView.backgroundColor = AppTheme.current.colors.middlegroundColor
    }
    
    private func reloadSettings() {
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
        case .proVersion: cellIdentifier = SettingsProVersionCell.identifier
        case .proVersionFeatures: cellIdentifier = SettingsProVersionFeaturesCell.identifier
        case .backgroundImage: cellIdentifier = SettingsBackgroundImageCell.identifier
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! BaseSettingsCell
        
        cell.setDisplayItem(item)
        cell.setupAppearance()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingsItems[section].0.title
    }
    
}

extension SettingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = settingsItems[indexPath.section].1[indexPath.row]
        item.action?()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1, !ProVersionPurchase.shared.isPurchased(), indexPath.row == 1, areProVersionFeaturesShown {
            return UITableViewAutomaticDimension
        }
        return 52
    }
    
}

fileprivate extension SettingsViewController {
    
    func makeSettingsItems() -> [(SettingsSection, [SettingsItem])] {
        var settings: [(SettingsSection, [SettingsItem])] = [
            (.general, makeGeneralSectionItems()),
            (.security, makeSecuritySectionItems()),
            (.about, makeAboutSectionItems())
        ]
        
        if !ProVersionPurchase.shared.isPurchased() {
            settings.insert((.proVersion, makeProVersionSectionItems()), at: 1)
        }
        
        return settings
    }
    
    func makeGeneralSectionItems() -> [SettingsItem] {
        var generalSectionItems: [SettingsItem] = []
        
        let currentTheme = AppThemeType.current
        let themeAction = { [unowned self] in
            UserProperty.appTheme.setInt(currentTheme.next.rawValue)
            self.setupAppearance()
            self.reloadSettings()
        }
        let themeItem = SettingsItem(title: "theme".localized,
                                     subtitle: currentTheme.title,
                                     icon: #imageLiteral(resourceName: "artListIcon"),
                                     isOn: false,
                                     isDetailed: false,
                                     style: .titleWithSubtitle,
                                     action: themeAction)
        
        
        generalSectionItems.append(themeItem)
        
        if ProVersionPurchase.shared.isPurchased() {
            let backgroundImageAction = { [unowned self] in
                self.performSegue(withIdentifier: "ShowBackgroundImagePicker", sender: nil)
            }
            let backgroundImageItem = SettingsItem(title: "background_image".localized,
                                                   subtitle: nil,
                                                   icon: BackgroundImage.current.image,
                                                   style: .backgroundImage,
                                                   action: backgroundImageAction)
            
            generalSectionItems.append(backgroundImageItem)
        }
        
        return generalSectionItems
    }
    
    func makeProVersionSectionItems() -> [SettingsItem] {
        var proVersionSectionItems: [SettingsItem] = []
        
        let buyProVersionAction = { [unowned self] in
            self.setLoadingVisible(true)
            ProVersionPurchase.shared.requestData { [weak self] in
                ProVersionPurchase.shared.purchase {
                    self?.setLoadingVisible(false)
                    self?.reloadSettings()
                }
            }
        }
        var buyProVersionItem = SettingsItem(title: "pro_version".localized,
                                             subtitle: "pro_version_price".localized,
                                             icon: #imageLiteral(resourceName: "crown"),
                                             style: .proVersion,
                                             action: buyProVersionAction)
        buyProVersionItem.helpAction = { [unowned self] in
            self.areProVersionFeaturesShown = !self.areProVersionFeaturesShown
            self.settingsItems = self.makeSettingsItems()
            if self.areProVersionFeaturesShown {
                self.tableView.insertRows(at: [IndexPath(row: 1, section: 1)], with: .middle)
            } else {
                self.tableView.deleteRows(at: [IndexPath(row: 1, section: 1)], with: .middle)
            }
        }
        
        proVersionSectionItems.append(buyProVersionItem)
        
        if areProVersionFeaturesShown {
            let features = (1..<6).map { "pro_version_feature_\($0)".localized }
            let featuresItem = SettingsItem(title: features.map { "- " + $0 }.joined(separator: "\n"),
                                            icon: UIImage(),
                                            style: .proVersionFeatures,
                                            action: nil)
            
            proVersionSectionItems.append(featuresItem)
        }
        
        let restoreProVersionAction = { [unowned self] in
            self.setLoadingVisible(true)
            ProVersionPurchase.shared.restore { success in
                self.setLoadingVisible(false)
                self.showErrorAlert(title: "error".localized, message: "restore_error_try_again".localized)
            }
        }
        let restoreProVersionItem = SettingsItem(title: "restore_pro_version".localized,
                                                 icon: #imageLiteral(resourceName: "repeat"),
                                                 style: .title,
                                                 action: restoreProVersionAction)
        
        proVersionSectionItems.append(restoreProVersionItem)
        
        return proVersionSectionItems
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
                                       icon: #imageLiteral(resourceName: "key"),
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
                                          icon: biometricsType.settingsImage,
                                          isOn: isBiometricsEnabled,
                                          isSelectable: false,
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
            if let url = URL(string: "itms-apps://itunes.apple.com/app/id1330119990") { // TODO: Right link
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            UserProperty.isAppRated.setBool(true)
        }
        let rateItem = SettingsItem(title: "rate".localized,
                                    icon: #imageLiteral(resourceName: "starListIcon"),
                                    isDetailed: true,
                                    style: .detailsTitle,
                                    action: rateAction)
        
        if !isAppRated {
            aboutSectionItems.append(rateItem)
        }
        
        let mailAction = { [unowned self] in
            let viewController = ViewControllersFactory.mail
            viewController.mailComposeDelegate = self
            self.present(viewController, animated: true, completion: nil)
        }
        let mailItem = SettingsItem(title: "mail_us".localized,
                                    icon: #imageLiteral(resourceName: "mailListIcon"),
                                    isDetailed: true,
                                    style: .detailsTitle,
                                    action: mailAction)
        
        if MFMailComposeViewController.canSendMail() {
            aboutSectionItems.append(mailItem)
        }
        
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let versionItem = SettingsItem(title: "version".localized,
                                       subtitle: version,
                                       icon: #imageLiteral(resourceName: "homeListIcon"),
                                       isDetailed: true,
                                       isSelectable: false,
                                       style: .titleWithSubtitle,
                                       action: nil)
        
        aboutSectionItems.append(versionItem)
        
        return aboutSectionItems
    }
    
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
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
    
    func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "close".localized, style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
}