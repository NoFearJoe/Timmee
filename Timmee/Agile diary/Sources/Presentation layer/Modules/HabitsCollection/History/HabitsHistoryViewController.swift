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
    
    unowned var pickedHabitsState: PickedHabitsState!
    
    @IBOutlet private var tableView: UITableView!
    
    @IBOutlet private var placeholderContainer: UIView!
    let placeholderView = PlaceholderView.loadedFromNib()
    
    private let habitsService = ServicesAssembly.shared.habitsService
    private lazy var cacheObserver = habitsService.habitsBySprintObserver(excludingSprintWithID: sprintID)
    private lazy var cacheSubscriber = TableViewCacheAdapter(tableView: tableView)
    
    override func prepare() {
        super.prepare()
        setupPlaceholder()
        setupCacheObserver()
        tableView.register(TableHeaderViewWithTitle.self, forHeaderFooterViewReuseIdentifier: "Header")
        tableView.register(HabitsHistoryCell.self, forCellReuseIdentifier: HabitsHistoryCell.reuseIdentifier)
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
    
    func changeBottomContentInset(by value: CGFloat) {
        tableView.contentInset.bottom = value
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
        let cell = tableView.dequeueReusableCell(withIdentifier: HabitsHistoryCell.reuseIdentifier, for: indexPath) as! HabitsHistoryCell
        let habit = cacheObserver.item(at: indexPath)
        let isPicked = pickedHabitsState.pickedHabits.contains(habit)
        cell.configure(habit: habit, isPicked: isPicked)
        return cell
    }
    
}

extension HabitsHistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let habit = cacheObserver.item(at: indexPath)
        let isPicked = pickedHabitsState.pickedHabits.contains(habit)
        if isPicked {
            pickedHabitsState.pickedHabits.remove(object: habit)
        } else {
            pickedHabitsState.pickedHabits.append(habit)
        }
        tableView.reloadData()
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
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
    }
    
    private func setupBackgroundView() {
        backgroundView = UIView(frame: .zero)
        backgroundView?.backgroundColor = AppTheme.current.colors.middlegroundColor
    }
    
    private func setupTitleLabel() {
        addSubview(titleLabel)
        titleLabel.font = AppTheme.current.fonts.medium(14)
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        titleLabel.clipsToBounds = true
        titleLabel.layer.cornerRadius = 6
        [titleLabel.leading(15), titleLabel.trailing(15), titleLabel.top(4)].toSuperview()
        titleLabel.centerY().toSuperview()
    }
    
}
