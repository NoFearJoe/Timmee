//
//  HabitsCollectionViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 09.11.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import Workset
import UIComponents

final class HabitsCollectionViewController: BaseViewController {
    
    var sprintID: String!
    
    @IBOutlet private var headerView: LargeHeaderView!
    @IBOutlet private var sectionSwitcher: Switcher!
    
    @IBOutlet private var shopContainerView: UIView!
    
    private var shopViewController: ShopCategoriesViewController!
    private lazy var historyViewController = HabitsPickerViewController(
        mode: .history(excludingSprintID: sprintID),
        pickedHabits: [],
        pickHabits: { [weak self] habits, completion in
            guard let self = self else { return }
            
            ServicesAssembly.shared.habitsService.addHabits(
                habits,
                sprintID: self.sprintID,
                goalID: nil
            ) { [weak self] _ in
                completion()
            }
        }
    )
        
    // MARK: - State
    
    private var currentSection: Section = .history
        
    override func prepare() {
        super.prepare()
        
        headerView.titleLabel.text = "Collection".localized
        
        sectionSwitcher.items = [Section.shop.title, Section.history.title]
        sectionSwitcher.selectedItemIndex = 0
        sectionSwitcher.addTarget(self, action: #selector(onSwitchSection), for: .touchUpInside)
        
        setupHistoryViewController()
        
        shopContainerView.isHidden = false
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
            shopViewController?.sprintID = sprintID
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func setSectionContainersVisible(shop: Bool, history: Bool) {
        shopViewController.performAppearanceTransition(isAppearing: shop) { shopContainerView.isHidden = !shop }
        historyViewController.performAppearanceTransition(isAppearing: history) { historyViewController.view.isHidden = !history }
    }
    
}

private extension HabitsCollectionViewController {
    
    func setupHistoryViewController() {
        historyViewController.view.isHidden = true
        historyViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(historyViewController)
        view.addSubview(historyViewController.view)
        historyViewController.didMove(toParent: self)
        
        historyViewController.view.topToBottom().to(headerView, addTo: view)
        historyViewController.view.bottom().to(view)
        if #available(iOS 11.0, *) {
            [historyViewController.view.leading(), historyViewController.view.trailing()].to(view.safeAreaLayoutGuide)
        } else {
            [historyViewController.view.leading(), historyViewController.view.trailing()].to(view)
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
