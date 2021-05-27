//
//  ShopCategoryViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 25.02.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class ShopCategoryViewController: BaseViewController {
    
    var collection: HabitsCollection?
    var sprintID: String?
        
    @IBOutlet private var headerView: LargeHeaderView!
    @IBOutlet private var tableView: UITableView!
    
    @IBOutlet private var placeholderContainer: UIView!
    let placeholderView = PlaceholderView.loadedFromNib()
    
    private lazy var addHabitsManager = HabitsCollectionAddHabitsManager(
        sprintID: sprintID ?? "",
        copyHabitsBeforeAdd: true,
        initiallyPickedHabits: []
    )
    
    private let habitsService = ServicesAssembly.shared.habitsService
    
    @IBAction private func onTapToBackButton() {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func prepare() {
        super.prepare()
        
        isModalInPresentation = true
        
        setupPlaceholder()
        
        tableView.register(HabitsPickerCell.self, forCellReuseIdentifier: HabitsPickerCell.reuseIdentifier)
        
        addHabitsManager.scrollView = tableView
        addHabitsManager.onAddHabits = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        addHabitsManager.setupAddHabitsButton(view: view)
        addHabitsManager.setAddHabitsButtonVisible(false, animated: false)
    }
    
    override func refresh() {
        super.refresh()
        headerView.titleLabel.text = collection?.title
        updatePlaceholderVisibility()
        tableView.reloadData()
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        setupPlaceholderAppearance()
        tableView.backgroundColor = AppTheme.current.colors.middlegroundColor
    }
    
}

extension ShopCategoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection?.habits.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HabitsPickerCell.reuseIdentifier, for: indexPath) as! HabitsPickerCell
        if let habit = collection?.habits.item(at: indexPath.row) {
            let isPicked = addHabitsManager.pickedHabits.contains(habit)
            cell.configure(habit: habit, isPicked: isPicked)
        }
        return cell
    }
    
}

extension ShopCategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let habit = collection?.habits.item(at: indexPath.row) else { return }
        let isPicked = addHabitsManager.pickedHabits.contains(habit)
        if isPicked {
            addHabitsManager.remove(habit: habit)
        } else {
            addHabitsManager.add(habit: habit)
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
}

private extension ShopCategoryViewController {
    
    func setupPlaceholder() {
        placeholderView.icon = UIImage(imageLiteralResourceName: "history")
        placeholderView.title = "there_is_no_habits_in_history".localized
        placeholderView.subtitle = "complete_one_more_sprint_to_see_history".localized
        placeholderView.setup(into: placeholderContainer)
        placeholderContainer.isHidden = true
    }
    
    func setupPlaceholderAppearance() {
        placeholderView.backgroundColor = .clear
        placeholderView.titleLabel.font = AppTheme.current.fonts.medium(18)
        placeholderView.subtitleLabel.font = AppTheme.current.fonts.regular(14)
        placeholderView.titleLabel.textColor = AppTheme.current.textColorForTodayLabelsOnBackground
        placeholderView.subtitleLabel.textColor = AppTheme.current.textColorForTodayLabelsOnBackground
    }
    
    func updatePlaceholderVisibility() {
        guard let collection = collection else { return }
        placeholderContainer.isHidden = !collection.habits.isEmpty
    }
    
}
