//
//  SettingsCells.swift
//  Agile diary
//
//  Created by Илья Харабет on 18.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

class BaseSettingsCell: UITableViewCell {
    
    class var identifier: String { return "" }
    
    func setDisplayItem(_ item: SettingsItem) {
        selectionStyle = item.isSelectable ? .default : .none
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupAppearance()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setupAppearance()
    }
    
    func setupAppearance() {
        tintColor = AppTheme.current.colors.mainElementColor
        backgroundColor = AppTheme.current.colors.foregroundColor
    }
    
}

class SettingsCellWithTitle: BaseSettingsCell {
    
    override class var identifier: String { return "SettingsCellWithTitle" }
    
    @IBOutlet private var iconView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    
    override func setDisplayItem(_ item: SettingsItem) {
        super.setDisplayItem(item)
        iconView.image = item.icon
        titleLabel.text = item.title
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconView.image = nil
        titleLabel.text = nil
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        iconView?.tintColor = AppTheme.current.colors.inactiveElementColor
        titleLabel?.textColor = AppTheme.current.colors.activeElementColor
    }
    
}

class SettingsCellWithTitleAndSubtitle: SettingsCellWithTitle {
    
    override class var identifier: String { return "SettingsCellWithTitleAndSubtitle" }
    
    @IBOutlet fileprivate var subtitleLabel: UILabel!
    
    override func setDisplayItem(_ item: SettingsItem) {
        super.setDisplayItem(item)
        subtitleLabel.text = item.subtitle
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        subtitleLabel.text = nil
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        subtitleLabel?.textColor = AppTheme.current.colors.mainElementColor
    }
    
}

final class SettingsCellWithTitleAndSwitch: SettingsCellWithTitle {
    
    override static var identifier: String { return "SettingsCellWithTitleAndSwitch" }
    
    @IBOutlet fileprivate var switcher: UISwitch!
    
    fileprivate var action: (() -> Void)?
    
    override func setDisplayItem(_ item: SettingsItem) {
        super.setDisplayItem(item)
        switcher.isOn = item.isOn
        action = item.action
    }
    
    @IBAction func onSwitch() {
        action?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        switcher.isOn = false
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        switcher?.tintColor = AppTheme.current.colors.decorationElementColor
        switcher?.onTintColor = AppTheme.current.colors.selectedElementColor
    }
    
}

final class SettingsDetailsCellWithTitle: SettingsCellWithTitle {
    
    override static var identifier: String { return "SettingsDetailsCellWithTitle" }
    
    override func setDisplayItem(_ item: SettingsItem) {
        super.setDisplayItem(item)
        accessoryType = .disclosureIndicator
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryType = .none
    }
    
}

final class SettingsDetailsCellWithTitleAndSubtitle: SettingsCellWithTitleAndSubtitle {
    
    override static var identifier: String { return "SettingsDetailsCellWithTitleAndSubtitle" }
    
    override func setDisplayItem(_ item: SettingsItem) {
        super.setDisplayItem(item)
        accessoryType = .disclosureIndicator
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryType = .none
    }
    
}

final class SettingsProVersionCell: SettingsCellWithTitleAndSubtitle {
    
    override static var identifier: String { return "SettingsProVersionCell" }
    
    private var onHelp: (() -> Void)?
    
    override func setDisplayItem(_ item: SettingsItem) {
        super.setDisplayItem(item)
        onHelp = item.helpAction
    }
    
    @IBAction func onHelpButtonTap() {
        onHelp?()
    }
    
}

final class SettingsProVersionFeaturesCell: BaseSettingsCell {
    
    override static var identifier: String { return "SettingsProVersionFeaturesCell" }
    
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.text = "pro_version_features_title".localized
        }
    }
    @IBOutlet private var featuresLabel: UILabel!
    
    override func setDisplayItem(_ item: SettingsItem) {
        featuresLabel.text = item.title
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        titleLabel?.textColor = AppTheme.current.colors.activeElementColor
        featuresLabel?.textColor = AppTheme.current.colors.inactiveElementColor
    }
    
}

final class SettingsBackgroundImageCell: BaseSettingsCell {
    
    override static var identifier: String { return "SettingsBackgroundImageCell" }
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var backgroundImageView: UIImageView!
    
    override func setDisplayItem(_ item: SettingsItem) {
        super.setDisplayItem(item)
        titleLabel.text = item.title
        backgroundImageView.image = item.icon
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        titleLabel?.textColor = AppTheme.current.colors.activeElementColor
        backgroundImageView?.layer.cornerRadius = 8
        backgroundImageView?.layer.masksToBounds = true
    }
    
}
