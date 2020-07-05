//
//  IntentViewController.swift
//  Agilee diary Siri IntentUI
//
//  Created by Илья Харабет on 04.07.2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import IntentsUI
import TasksKit
import UIComponents

class IntentViewController: UIViewController, INUIHostedViewControlling, SprintInteractorTrait {
    
    let contentView = UITableView(frame: .zero, style: .plain)
    
    let sprintsService = ServicesAssembly.shared.sprintsService
    private let habitsService = ServicesAssembly.shared.habitsService
    
    private lazy var cacheAdapter = TableViewCacheAdapter(tableView: contentView)
    private var habitsCacheObserver: CachedEntitiesObserver<HabitEntity, Habit>?
    
    private let currentDate = Date.now
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppTheme.current.colors.middlegroundColor
        
        setupContentView()
        
        if let sprint = getCurrentSprint() {
            setupHabitsCacheObserver(forSection: .habits, sprintID: sprint.id)
        }
    }
        
    // MARK: - INUIHostedViewControlling
    
    func configureView(
        for parameters: Set<INParameter>,
        of interaction: INInteraction,
        interactiveBehavior: INUIInteractiveBehavior,
        context: INUIHostedViewContext,
        completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void
    ) {
        completion(true, parameters, self.desiredSize)
    }
    
    var height: CGFloat = 0
    var desiredSize: CGSize {
        CGSize(
            width: extensionContext!.hostedViewMaximumAllowedSize.width,
            height: min(height, extensionContext!.hostedViewMaximumAllowedSize.height)
        )
    }
    
    private func setupContentView() {
        view.addSubview(contentView)
        
        if #available(iOS 11.0, *) {
            contentView.allEdges().to(view)
        } else {
            contentView.allEdges().to(view)
        }
        
        contentView.delegate = self
        contentView.dataSource = self
        
        contentView.contentInset.top = 8
        contentView.contentInset.bottom = 8
        contentView.estimatedRowHeight = 56
        contentView.rowHeight = UITableView.automaticDimension
        contentView.showsVerticalScrollIndicator = false
        contentView.tableFooterView = UIView()
        contentView.separatorStyle = .none
        contentView.delaysContentTouches = false
        
        contentView.backgroundColor = .clear
        
        contentView.register(
            TodayHabitCell.self,
            forCellReuseIdentifier: TodayHabitCell.identifier
        )
        contentView.register(
            TableHeaderViewWithTitle.self,
            forHeaderFooterViewReuseIdentifier: "Header"
        )
                
        cacheAdapter.tableView = contentView
    }
    
    func setupHabitsCacheObserver(forSection section: SprintSection, sprintID: String) {
        habitsCacheObserver = ServicesAssembly.shared.habitsService.habitsScope(
            sprintID: sprintID,
            day: DayUnit(weekday: currentDate.weekday),
            date: currentDate.endOfDay() ?? currentDate.endOfDay
        )
        let delegate = CachedEntitiesObserverDelegate<Habit>(
            onInitialFetch: nil,
            onEntitiesCountChange: { [unowned self] count in
                let headersHeight = CGFloat(self.habitsCacheObserver!.numberOfSections()) * 28
                let cellsHeight = 56 * CGFloat(count) + 16
                let widgetBottomAdditionalHeight = CGFloat(32)
                self.height = cellsHeight + headersHeight + widgetBottomAdditionalHeight
            },
            onChanges: nil,
            onBatchUpdatesCompleted: nil
        )
        habitsCacheObserver?.setDelegate(delegate)
        habitsCacheObserver?.setSubscriber(cacheAdapter)
        habitsCacheObserver?.fetch()
    }
    
}

extension IntentViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        habitsCacheObserver?.numberOfSections() ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        habitsCacheObserver?.numberOfItems(in: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TodayHabitCell.identifier, for: indexPath) as! TodayHabitCell
        if let habit = habitsCacheObserver?.item(at: indexPath) {
            cell.configure(habit: habit, currentDate: currentDate)
            cell.setFlat(false)
            cell.setCheckboxVisible(false)
            cell.setHoriznotalInsets(15)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionName = habitsCacheObserver?.sectionInfo(at: section)?.name else { return nil }
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Header") as! TableHeaderViewWithTitle
        view.titleLabel.backgroundColor = .clear
        view.backgroundView?.backgroundColor = AppTheme.current.colors.middlegroundColor
        let dayTime = Habit.DayTime(sortID: sectionName)
        view.titleLabel.text = dayTime.localizedAt
        return view
    }
    
}
