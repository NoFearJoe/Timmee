//
//  HabitsCollectionViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 09.11.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class HabitsCollectionViewController: BaseViewController {
    
    var sprintID: String!
    
    @IBOutlet private var headerView: LargeHeaderView!
    @IBOutlet private var sectionSwitcher: Switcher!
    
    @IBOutlet private var shopContainerView: UIView!
    @IBOutlet private var historyContainerView: UIView!
    
    private var shopViewController: ShopCategoriesViewController!
    private var historyViewController: HabitsHistoryViewController!
    
    private var currentSection: Section = .history
    
    override func prepare() {
        super.prepare()
        
        headerView.titleLabel.text = "Collection".localized
        
        sectionSwitcher.items = [Section.shop.title, Section.history.title]
        sectionSwitcher.selectedItemIndex = 0
        sectionSwitcher.addTarget(self, action: #selector(onSwitchSection), for: .touchUpInside)
        
        shopContainerView.isHidden = false
        historyContainerView.isHidden = true
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        
        view.backgroundColor = AppTheme.current.colors.middlegroundColor
        headerView.titleLabel.textColor = AppTheme.current.colors.activeElementColor
        headerView.leftButton?.tintColor = AppTheme.current.colors.activeElementColor
        headerView.backgroundColor = AppTheme.current.colors.foregroundColor
        sectionSwitcher.setupAppearance()
    }
    
    @IBAction private func onTapToCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func onSwitchSection() {
        currentSection = Section(rawValue: sectionSwitcher.selectedItemIndex) ?? .shop
        switch currentSection {
        case .shop:
            setSectionContainersVisible(shop: true, history: false)
        case .history:
            setSectionContainersVisible(shop: false, history: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Shop" {
            shopViewController = segue.destination as? ShopCategoriesViewController
        } else if segue.identifier == "History" {
            historyViewController = segue.destination as? HabitsHistoryViewController
            historyViewController?.sprintID = sprintID
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func setSectionContainersVisible(shop: Bool, history: Bool) {
        shopViewController.performAppearanceTransition(isAppearing: shop) { shopContainerView.isHidden = !shop }
        historyViewController.performAppearanceTransition(isAppearing: history) { historyContainerView.isHidden = !history }
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
