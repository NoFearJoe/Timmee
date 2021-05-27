//
//  HabitsPickerViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 13.11.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import TasksKit
import UIComponents

final class HabitsPickerViewController: BaseViewController {
    
    enum Mode {
        case history(excludingSprintID: String)
        case sprint(id: String)
        
        var sprintID: String {
            switch self {
            case let .history(excludingSprintID): return excludingSprintID
            case let .sprint(id): return id
            }
        }
    }
        
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    let placeholderView = PlaceholderView.loadedFromNib()
    
    private let addHabitsManager: HabitsCollectionAddHabitsManager
    
    private let habitsService = ServicesAssembly.shared.habitsService
    private lazy var cacheObserver: CacheObserver<Habit> = {
        switch mode {
        case let .history(excludingSprintID):
            return habitsService.habitsBySprintObserver(excludingSprintWithID: mode.sprintID)
        case let .sprint(id):
            return habitsService.habitsObserver(sprintID: id, day: nil)
        }
    }()
    private lazy var cacheSubscriber = TableViewCacheAdapter(tableView: tableView)
    
    private let mode: Mode
    private let pickHabits: ([Habit], @escaping () -> Void) -> Void
    
    init(mode: Mode, pickedHabits: [Habit], pickHabits: @escaping ([Habit], @escaping () -> Void) -> Void) {
        self.mode = mode
        self.pickHabits = pickHabits
        
        addHabitsManager = HabitsCollectionAddHabitsManager(
            sprintID: mode.sprintID,
            copyHabitsBeforeAdd: false,
            initiallyPickedHabits: pickedHabits
        )
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func prepare() {
        super.prepare()
        
        setupNavigationBar()
        setupTableView()
        setupPlaceholder()
        setupCacheObserver()
        
        tableView.register(TableHeaderViewWithTitle.self, forHeaderFooterViewReuseIdentifier: "Header")
        tableView.register(HabitsPickerCell.self, forCellReuseIdentifier: HabitsPickerCell.reuseIdentifier)
        
        addHabitsManager.scrollView = tableView
        addHabitsManager.addHabits = { [weak self] habits, completion in
            self?.pickHabits(habits, completion)
        }
        addHabitsManager.onAddHabits = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        addHabitsManager.setupAddHabitsButton(view: view)
        addHabitsManager.setAddHabitsButtonVisible(false, animated: false)
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
    
    @objc private func didTapCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension HabitsPickerViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cacheObserver.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cacheObserver.numberOfItems(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HabitsPickerCell.reuseIdentifier, for: indexPath) as! HabitsPickerCell
        let habit = cacheObserver.item(at: indexPath)
        let isPicked = addHabitsManager.pickedHabits.contains(habit)
        cell.configure(habit: habit, isPicked: isPicked)
        return cell
    }
    
}

extension HabitsPickerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let habit = cacheObserver.item(at: indexPath)
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch mode {
        case .history:
            return 28
        case .sprint:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header") as! TableHeaderViewWithTitle
        if let sprintNumber = cacheObserver.sectionInfo(at: section)?.name {
            view.titleLabel.text = "Sprint".localized + " #" + sprintNumber
        }
        return view
    }
    
}

private extension HabitsPickerViewController {
    
    func setupCacheObserver() {
        cacheObserver.setSubscriber(cacheSubscriber)
        cacheObserver.setActions(
            onInitialFetch: { [unowned self] in self.updatePlaceholderVisibility() },
            onItemsCountChange: nil,
            onItemChange: nil,
            onBatchUpdatesStarted: nil,
            onBatchUpdatesCompleted: nil)
    }
    
    func setupNavigationBar() {
        guard navigationController?.viewControllers.count == 1 else { return }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "cross"), style: .plain, target: self, action: #selector(didTapCloseButton))
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.alwaysBounceVertical = true
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
        tableView.allEdges().toSuperview()
    }
    
    func setupPlaceholder() {
        placeholderView.icon = UIImage(imageLiteralResourceName: "history")
        placeholderView.title = "there_is_no_habits_in_history".localized
        placeholderView.subtitle = "complete_one_more_sprint_to_see_history".localized
        placeholderView.setup(into: view)
        placeholderView.isHidden = true
    }
    
    func setupPlaceholderAppearance() {
        placeholderView.backgroundColor = .clear
        placeholderView.titleLabel.font = AppTheme.current.fonts.medium(18)
        placeholderView.subtitleLabel.font = AppTheme.current.fonts.regular(14)
        placeholderView.titleLabel.textColor = AppTheme.current.colors.activeElementColor
        placeholderView.subtitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
    }
    
    func updatePlaceholderVisibility() {
        placeholderView.isHidden = cacheObserver.numberOfSections() != 0
    }
    
}
