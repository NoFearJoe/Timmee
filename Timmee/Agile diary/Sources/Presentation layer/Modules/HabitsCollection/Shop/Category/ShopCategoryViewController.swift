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
    
    private let habitsService = ServicesAssembly.shared.habitsService
    
    private var pickedHabbitIDs: [(original: String, new: String)] = []
    
    @IBAction private func onTapToBackButton() {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func prepare() {
        super.prepare()
        setupPlaceholder()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShopCategoryHabitCell", for: indexPath) as! ShopCategoryHabitCell
        if let habit = collection?.habits.item(at: indexPath.row) {
            let isPicked = pickedHabbitIDs.contains(where: { $0.original == habit.id })
            cell.configure(habit: habit, isPicked: isPicked)
        }
        return cell
    }
    
}

extension ShopCategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let habit = collection?.habits.item(at: indexPath.row) else { return }
        if let pickedHabitID = pickedHabbitIDs.first(where: { $0.original == habit.id })?.new {
            let pickedHabit = habit.copy
            pickedHabit.id = pickedHabitID
            habitsService.removeHabit(pickedHabit) { [weak self] success in
                guard let self = self, success else { return }
                self.pickedHabbitIDs.removeAll(where: { $0.original == habit.id })
                self.tableView.reloadData()
            }
        } else {
            guard let sprintID = sprintID else { return }
            let newHabit = habit.copy
            newHabit.id = RandomStringGenerator.randomString(length: 24)
            habitsService.addHabit(newHabit, sprintID: sprintID) { [weak self] success in
                guard let self = self, success else { return }
                self.pickedHabbitIDs.append((original: habit.id, new: newHabit.id))
                self.tableView.reloadData()
            }
        }
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

final class ShopCategoryHabitCell: SprintCreationHabitCell {
    
    @IBOutlet private var checkbox: Checkbox!
    
    func configure(habit: Habit, isPicked: Bool) {
        configure(habit: habit)
        checkbox.isChecked = isPicked
    }
    
}
