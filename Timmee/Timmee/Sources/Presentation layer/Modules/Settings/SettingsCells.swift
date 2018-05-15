//
//  SettingsCells.swift
//  test_label
//
//  Created by i.kharabet on 20.10.17.
//  Copyright © 2017 i.kharabet. All rights reserved.
//

import UIKit

class BaseSettingsCell: UITableViewCell {
    
    class var identifier: String { return "" }
    
    func setDisplayItem(_ item: SettingsItem) {
        selectionStyle = item.isSelectable ? .default : .none
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = AppTheme.current.foregroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = AppTheme.current.foregroundColor
    }
    
}

class SettingsCellWithTitle: BaseSettingsCell {
    
    override class var identifier: String { return "SettingsCellWithTitle" }
    
    @IBOutlet fileprivate var iconView: UIImageView! {
        didSet {
            iconView.tintColor = AppTheme.white.scheme.secondaryTintColor
        }
    }
    @IBOutlet fileprivate var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = AppTheme.white.scheme.tintColor
        }
    }
    
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
    
}

class SettingsCellWithTitleAndSubtitle: SettingsCellWithTitle {
    
    override class var identifier: String { return "SettingsCellWithTitleAndSubtitle" }
    
    @IBOutlet fileprivate var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.textColor = AppTheme.white.scheme.blueColor
        }
    }
    
    override func setDisplayItem(_ item: SettingsItem) {
        super.setDisplayItem(item)
        subtitleLabel.text = item.subtitle
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        subtitleLabel.text = nil
    }
    
}

final class SettingsCellWithTitleAndSwitch: SettingsCellWithTitle {
    
    override static var identifier: String { return "SettingsCellWithTitleAndSwitch" }
    
    @IBOutlet fileprivate var switcher: UISwitch! {
        didSet {
            switcher.tintColor = AppTheme.current.panelColor
            switcher.onTintColor = AppTheme.white.scheme.greenColor
        }
    }
    
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

final class SettingsProVersionCell: SettingsCellWithTitle {
    
    override static var identifier: String { return "SettingsProVersionCell" }
    
    override func setDisplayItem(_ item: SettingsItem) {
        super.setDisplayItem(item)
        iconView.tintColor = AppTheme.current.yellowColor
    }
    
}
