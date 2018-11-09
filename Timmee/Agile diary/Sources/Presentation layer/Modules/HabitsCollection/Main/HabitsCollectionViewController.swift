//
//  HabitsCollectionViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 09.11.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class HabitsCollectionViewController: BaseViewController {
    
    @IBOutlet private var headerView: LargeHeaderView!
    @IBOutlet private var sectionSwitcher: Switcher!
    
    private var currentSection: Section = .shop
    
    override func prepare() {
        super.prepare()
        
        sectionSwitcher.items = [Section.shop.title, Section.history.title]
        sectionSwitcher.selectedItemIndex = 0
        sectionSwitcher.addTarget(self, action: #selector(onSwitchSection), for: .touchUpInside)
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        
        view.backgroundColor = AppTheme.current.colors.middlegroundColor
        headerView.titleLabel.textColor = AppTheme.current.colors.activeElementColor
        headerView.subtitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        headerView.leftButton?.tintColor = AppTheme.current.colors.activeElementColor
        headerView.rightButton?.tintColor = AppTheme.current.colors.mainElementColor
        headerView.backgroundColor = AppTheme.current.colors.foregroundColor
        sectionSwitcher.setupAppearance()
    }
    
    @objc private func onSwitchSection() {
        currentSection = Section(rawValue: sectionSwitcher.selectedItemIndex) ?? .shop
        switch currentSection {
        case .shop: break
//            setSectionContainersVisible(content: true, water: false)
        case .history: break
//            setSectionContainersVisible(content: false, water: true)
        }
    }
    
}

private extension HabitsCollectionViewController {
    
    enum Section: Int {
        case shop, history
        
        var title: String {
            switch self {
            case .shop: return "habits_collection_shop_section_title".localized
            case .history: return "habits_collection_history_section_title".localized
            }
        }
    }
    
}
