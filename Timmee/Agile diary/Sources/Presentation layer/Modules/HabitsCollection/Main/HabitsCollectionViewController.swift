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

protocol PickedHabitsState: AnyObject {
    var pickedHabits: [Habit] { get set }
}

final class HabitsCollectionViewController: BaseViewController, PickedHabitsState {
    
    var sprintID: String!
    
    @IBOutlet private var headerView: LargeHeaderView!
    @IBOutlet private var sectionSwitcher: Switcher!
    
    @IBOutlet private var shopContainerView: UIView!
    @IBOutlet private var historyContainerView: UIView!
    
    private var shopViewController: ShopCategoriesViewController!
    private var historyViewController: HabitsHistoryViewController!
    
    private let addHabitsButton = UIButton(type: .custom)
    
    // MARK: - State
    
    private var currentSection: Section = .history
    
    var pickedHabits: [Habit] = [] {
        didSet {
            setAddHabitsButtonVisible(!pickedHabits.isEmpty, animated: true)
            if !pickedHabits.isEmpty {
                addHabitsButton.setTitle(String.localizedAddNHabits(count: pickedHabits.count), for: .normal)
            }
        }
    }
    
    private var isAddHabitsButtonVisible: Bool = true
    
    override func prepare() {
        super.prepare()
        
        headerView.titleLabel.text = "Collection".localized
        
        sectionSwitcher.items = [Section.shop.title, Section.history.title]
        sectionSwitcher.selectedItemIndex = 0
        sectionSwitcher.addTarget(self, action: #selector(onSwitchSection), for: .touchUpInside)
        
        shopContainerView.isHidden = false
        historyContainerView.isHidden = true
        
        setupAddHabitsButton()
        setAddHabitsButtonVisible(false, animated: false)
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        
        view.backgroundColor = AppTheme.current.colors.middlegroundColor
        headerView.titleLabel.textColor = AppTheme.current.colors.activeElementColor
        headerView.leftButton?.tintColor = AppTheme.current.colors.activeElementColor
        headerView.backgroundColor = AppTheme.current.colors.foregroundColor
        sectionSwitcher.setupAppearance()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        addHabitsButton.roundCorners(corners: .allCorners, radius: 6)
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
            shopViewController?.pickedHabitsState = self
        } else if segue.identifier == "History" {
            historyViewController = segue.destination as? HabitsHistoryViewController
            historyViewController?.sprintID = sprintID
            historyViewController?.pickedHabitsState = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func setSectionContainersVisible(shop: Bool, history: Bool) {
        shopViewController.performAppearanceTransition(isAppearing: shop) { shopContainerView.isHidden = !shop }
        historyViewController.performAppearanceTransition(isAppearing: history) { historyContainerView.isHidden = !history }
    }
    
    // MARK: Add habits button
    
    private func setupAddHabitsButton() {
        view.addSubview(addHabitsButton)
        view.bringSubviewToFront(addHabitsButton)
        addHabitsButton.addTarget(self, action: #selector(onTapToAddHabitsButton), for: .touchUpInside)
        addHabitsButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        addHabitsButton.setTitleColor(.white, for: .normal)
        addHabitsButton.configureShadow(radius: 8, opacity: 0.1)
        
        // TODO: Add constraints for iPad
        [addHabitsButton.centerX()].toSuperview()
        addHabitsButton.height(52)
        if UIDevice.current.isIpad {
            addHabitsButton.width(360)
        } else {
            addHabitsButton.leading(16).toSuperview()
        }
        if #available(iOS 11.0, *) {
            addHabitsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        } else {
            addHabitsButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -16).isActive = true
        }
    }
    
    private func setAddHabitsButtonVisible(_ visible: Bool, animated: Bool) {
        guard isAddHabitsButtonVisible != visible else { return }
        
        isAddHabitsButtonVisible = visible
        
        let animations = {
            let insetFromSafeArea: CGFloat = 52 + 16
            
            self.addHabitsButton.transform = visible ?
                .identity :
                CGAffineTransform(translationX: 0, y: insetFromSafeArea + 36)
            
            self.historyViewController?.changeBottomContentInset(by: visible ? insetFromSafeArea : 0)
            self.shopViewController?.changeBottomContentInset(by: visible ? insetFromSafeArea : 0)
        }
        
        if animated {
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: .curveEaseOut,
                           animations: animations,
                           completion: nil)
        } else {
            animations()
        }
    }
    
    @objc private func onTapToAddHabitsButton() {
        let newHabits = pickedHabits.map { habit -> Habit in
            let newHabit = habit.copy
            newHabit.id = RandomStringGenerator.randomString(length: 24)
            return newHabit
        }
        
        ServicesAssembly.shared.habitsService.addHabits(newHabits, sprintID: sprintID) { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
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
