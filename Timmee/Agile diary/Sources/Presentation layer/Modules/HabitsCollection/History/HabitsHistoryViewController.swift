//
//  HabitsHistoryViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 13.11.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class HabitsHistoryViewController: BaseViewController {
    
    var sprintID: String!
    
    @IBOutlet private var tableView: UITableView!
    
    @IBOutlet private var placeholderContainer: UIView!
    let placeholderView = PlaceholderView.loadedFromNib()
    
    private let habitsService = ServicesAssembly.shared.habitsService
    private lazy var cacheObserver = habitsService.habitsBySprintObserver(excludingSprintWithID: sprintID)
    private lazy var cacheSubscriber = TableViewCacheAdapter(tableView: tableView)
    
    private var pickedHabbitIDs: [(original: String, new: String)] = []
    
    override func prepare() {
        super.prepare()
        setupPlaceholder()
        setupCacheObserver()
        tableView.register(TableHeaderViewWithTitle.self, forHeaderFooterViewReuseIdentifier: "Header")
    }
    
    override func refresh() {
        super.refresh()
        cacheObserver.fetchInitialEntities()
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        setupPlaceholderAppearance()
        tableView.backgroundColor = AppTheme.current.colors.middlegroundColor
    }
    
}

extension HabitsHistoryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cacheObserver.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cacheObserver.numberOfItems(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HabitsHistoryCell", for: indexPath) as! HabitsHistoryCell
        let habit = cacheObserver.item(at: indexPath)
        let isPicked = pickedHabbitIDs.contains(where: { $0.original == habit.id })
        cell.configure(habit: habit, isPicked: isPicked)
        return cell
    }
    
}

extension HabitsHistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let habit = cacheObserver.item(at: indexPath)
        if let pickedHabitID = pickedHabbitIDs.first(where: { $0.original == habit.id })?.new {
            let pickedHabit = habit.copy
            pickedHabit.id = pickedHabitID
            habitsService.removeHabit(pickedHabit) { [weak self] success in
                guard let self = self, success else { return }
                self.pickedHabbitIDs.removeAll(where: { $0.original == habit.id })
                self.tableView.reloadData()
            }
        } else {
            let newHabit = habit.copy
            newHabit.doneDates = []
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header") as! TableHeaderViewWithTitle
        if let sprintNumber = cacheObserver.sectionInfo(at: section)?.name {
            view.titleLabel.text = "Sprint".localized + " #" + sprintNumber
        }
        return view
    }
    
}

private extension HabitsHistoryViewController {
    
    func setupCacheObserver() {
        cacheObserver.setSubscriber(cacheSubscriber)
        cacheObserver.setActions(
            onInitialFetch: { [unowned self] in self.updatePlaceholderVisibility() },
            onItemsCountChange: nil,
            onItemChange: nil,
            onBatchUpdatesStarted: nil,
            onBatchUpdatesCompleted: nil)
    }
    
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
        placeholderContainer.isHidden = cacheObserver.numberOfSections() != 0
    }
    
}

final class HabitsHistoryCell: SprintCreationHabitCell {
    
    @IBOutlet private var checkbox: Checkbox!
    
    func configure(habit: Habit, isPicked: Bool) {
        configure(habit: habit)
        checkbox.isChecked = isPicked
    }
    
}

final class TableHeaderViewWithTitle: UITableViewHeaderFooterView {
    
    let titleLabel: UILabel = UILabel(frame: .zero)
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupBackgroundView()
        setupTitleLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBackgroundView()
        setupTitleLabel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView?.frame = bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundView?.backgroundColor = AppTheme.current.colors.middlegroundColor
        titleLabel.textColor = AppTheme.current.colors.inactiveElementColor
    }
    
    private func setupBackgroundView() {
        backgroundView = UIView(frame: .zero)
        backgroundView?.backgroundColor = AppTheme.current.colors.middlegroundColor
    }
    
    private func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.font = AppTheme.current.fonts.medium(14)
        titleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        [titleLabel.leading(15), titleLabel.trailing(15)].toSuperview()
        titleLabel.centerY().toSuperview()
    }
    
}
