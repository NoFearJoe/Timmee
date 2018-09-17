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
            setupCacheObserver(forSection: currentSection, sprintID: sprint.id)
            contentViewController.sprintID = sprint.id
            updateHeaderSubtitle(sprint: sprint)
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
        } else if segue.identifier == "ShowTargetEditor" {
            guard let controller = segue.destination as? TargetCreationViewController else { return }
            controller.setTarget(sender as? Task, listID: sprint.id)
            controller.setEditingMode(.short)
        } else if segue.identifier == "ShowHabitEditor" {
            guard let controller = segue.destination as? HabitCreationViewController else { return }
            controller.setHabit(sender as? Task, listID: sprint.id)
            controller.setEditingMode(.short)
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
        let progress = CGFloat(tasks.filter { $0.isDone(at: Date()) }.count) / CGFloat(tasks.count)
        progressBar.setProgress(progress, animated: true)
    }
    
    private func setupCacheObserver(forSection section: SprintSection, sprintID: String) {
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
    
    private func updateHeaderSubtitle(sprint: Sprint) {
        let daysRemaining = Date().days(before: (sprint.creationDate + Constants.sprintDuration.asWeeks))
        let subtitle = NSMutableAttributedString()
        subtitle.append(NSAttributedString(string: "Sprint".localized, attributes: [.foregroundColor: AppTheme.current.colors.inactiveElementColor]))
        subtitle.append(NSAttributedString(string: " #\(sprint.sortPosition)", attributes: [.foregroundColor: AppTheme.current.colors.mainElementColor]))
        subtitle.append(NSAttributedString(string: ", " + "remains_n".localized(with: daysRemaining), attributes: [.foregroundColor: AppTheme.current.colors.inactiveElementColor]))
        subtitle.append(NSAttributedString(string: " \(daysRemaining) ", attributes: [.foregroundColor: AppTheme.current.colors.mainElementColor]))
        subtitle.append(NSAttributedString(string: "n_days".localized(with: daysRemaining), attributes: [.foregroundColor: AppTheme.current.colors.inactiveElementColor]))
        headerView.subtitleLabel.attributedText = subtitle
    }
    
}
