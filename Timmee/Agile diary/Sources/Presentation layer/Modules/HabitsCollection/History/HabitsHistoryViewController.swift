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
    private lazy var cacheObserver = habitsService.habitsBySprintObserver()
    private lazy var cacheSubscriber = TableViewCacheAdapter(tableView: tableView)
    
    override func prepare() {
        super.prepare()
        setupPlaceholder()
        setupCacheObserver()
        tableView.register(HabitsHistoryHeaderView.self, forHeaderFooterViewReuseIdentifier: "HabitsHistoryHeaderView")
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
        cell.configure(habit: habit)
        return cell
    }
    
}

extension HabitsHistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let habit = cacheObserver.item(at: indexPath)
        // TODO: Проверить, что привычка не добавлена в спринт
        let newHabit = habit.copy
        newHabit.id = RandomStringGenerator.randomString(length: 24)
        habitsService.addHabit(newHabit, sprintID: sprintID, completion: { success in
            print("\(success)")
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HabitsHistoryHeaderView") as! HabitsHistoryHeaderView
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
    
    @IBOutlet private var checkButton: UIButton!
    
}

final class HabitsHistoryHeaderView: UITableViewHeaderFooterView {
    
    let titleLabel: UILabel = UILabel(frame: .zero)
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = AppTheme.current.colors.middlegroundColor
        setupTitleLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView.backgroundColor = AppTheme.current.colors.middlegroundColor
        setupTitleLabel()
    }
    
    private func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.font = AppTheme.current.fonts.medium(14)
        titleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        [titleLabel.leading(15), titleLabel.trailing(15)].toSuperview()
        titleLabel.centerY().toSuperview()
    }
    
}
