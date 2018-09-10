//
//  TodayViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 10.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class TodayViewController: UIViewController, SprintInteractorTrait, AlertInput {
    
    @IBOutlet private var headerView: LargeHeaderView!
    @IBOutlet private var sectionSwitcher: Switcher!
    @IBOutlet private var progressBar: ProgressBar!
    
    private var contentViewController: TodayContentViewController!
    
    private var currentSection = SprintSection.habits
    
    private var cacheObserver: CacheObserver<Task>?
    
    var sprint: Sprint! {
        didSet {
            contentViewController.sprintID = sprint.id
            let daysRemaining = Date().days(before: (sprint.creationDate + Constants.sprintDuration.asWeeks))
            headerView.subtitleLabel.text = "Sprint".localized + " #\(sprint.sortPosition), " + "remains_n".localized(with: daysRemaining) + " \(daysRemaining) " + "n_days".localized(with: daysRemaining) // TODO: Выделить кол-во дней цветом
        }
    }
    
    let sprintsService = ServicesAssembly.shared.listsService
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.leftButton?.isHidden = true
        headerView.rightButton?.isHidden = true
        headerView.titleLabel.text = "today".localized
        sectionSwitcher.items = [SprintSection.habits.title, SprintSection.targets.title]
        sectionSwitcher.selectedItemIndex = 0
        sectionSwitcher.addTarget(self, action: #selector(onSwitchSection), for: .touchUpInside)
        progressBar.fillColor = AppTheme.current.colors.mainElementColor
        if sprint == nil {
            if let currentSprint = getCurrentSprint() {
                self.sprint = currentSprint
            } else if let nextSprint = getNextSprint() {
//                 Show next sprint placeholder???
            } else {
//                 Show placeholder
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SprintContent" {
            contentViewController = segue.destination as! TodayContentViewController
            contentViewController.section = currentSection
            contentViewController.transitionHandler = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    @objc private func onSwitchSection() {
        currentSection = SprintSection(rawValue: sectionSwitcher.selectedItemIndex) ?? .habits
        contentViewController.section = currentSection
        setupCacheObserver(forSection: currentSection, sprintID: sprint.id)
    }
    
    private func updateSprintProgress(tasks: [Task]) {
        let progress = CGFloat(tasks.filter { $0.isDone }.count) / CGFloat(tasks.count)
        progressBar.setProgress(progress, animated: true)
    }
    
    func setupCacheObserver(forSection section: SprintSection, sprintID: String) {
        let predicate = NSPredicate(format: "list.id = %@ AND kind = %@", sprintID, section.itemsKind.id)
        cacheObserver = ServicesAssembly.shared.tasksService.tasksObserver(predicate: predicate)
        cacheObserver?.setMapping { Task(task: $0 as! TaskEntity) }
        cacheObserver?.setActions(
            onInitialFetch: { [unowned self] in self.updateSprintProgress(tasks: self.cacheObserver?.items(in: 0) ?? []) },
            onItemsCountChange: nil,
            onItemChange: nil,
            onBatchUpdatesStarted: nil,
            onBatchUpdatesCompleted: { [unowned self] in self.updateSprintProgress(tasks: self.cacheObserver?.items(in: 0) ?? []) })
        cacheObserver?.fetchInitialEntities()
    }
    
}
