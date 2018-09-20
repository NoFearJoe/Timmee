//
//  TodayViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 10.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class TodayViewController: BaseViewController, SprintInteractorTrait, AlertInput {
    
    @IBOutlet private var headerView: LargeHeaderView!
    @IBOutlet private var sectionSwitcher: Switcher!
    @IBOutlet private var progressBar: ProgressBar!
    @IBOutlet private var createSprintButton: UIButton!
    @IBOutlet private var backgroundImageView: UIImageView!
    
    @IBOutlet private var placeholderContainer: UIView!
    private lazy var placeholderView = PlaceholderView.loadedFromNib()
    
    private var contentViewController: TodayContentViewController!
    
    private var currentSection = SprintSection.habits
    
    private var cacheObserver: CacheObserver<Task>?
    
    var sprint: Sprint! {
        didSet {
            hidePlaceholder()
            setupCacheObserver(forSection: currentSection, sprintID: sprint.id)
            contentViewController.sprintID = sprint.id
            updateHeaderSubtitle(sprint: sprint)
        }
    }
    
    let sprintsService = ServicesAssembly.shared.listsService
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.titleLabel.text = "today".localized
        if ProVersionPurchase.shared.isPurchased() {
            sectionSwitcher.items = [SprintSection.habits.title, SprintSection.targets.title, SprintSection.water.title]
        } else {
            sectionSwitcher.items = [SprintSection.habits.title, SprintSection.targets.title]
        }
        sectionSwitcher.selectedItemIndex = 0
        sectionSwitcher.addTarget(self, action: #selector(onSwitchSection), for: .touchUpInside)
        progressBar.setProgress(0)
        setupPlaceholder()
        if sprint == nil {
            if let currentSprint = getCurrentSprint() {
                createSprintButton.isHidden = true
                setSwitcherEnabled(true)
                sprint = currentSprint
            } else if let nextSprint = getNextSprint() {
                createSprintButton.isHidden = true
                setSwitcherEnabled(false)
                headerView.subtitleLabel.text = "next_sprint_starts".localized + " " + nextSprint.creationDate.asNearestShortDateString.lowercased()
                showNextSprintPlaceholder(sprintNumber: nextSprint.sortPosition, startDate: nextSprint.creationDate)
            } else {
                createSprintButton.isHidden = false
                setSwitcherEnabled(false)
                headerView.subtitleLabel.text = nil
                showCreateSprintPlaceholder()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ProVersionPurchase.shared.isPurchased() {
            backgroundImageView.image = BackgroundImage.current.image
        }
        setupCreateSprintButton()
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        view.backgroundColor = AppTheme.current.colors.middlegroundColor
        headerView.leftButton?.tintColor = AppTheme.current.colors.activeElementColor
        headerView.rightButton?.tintColor = AppTheme.current.colors.mainElementColor
        progressBar.fillColor = AppTheme.current.colors.mainElementColor
        headerView.backgroundColor = AppTheme.current.colors.middlegroundColor.withAlphaComponent(0.85)
        sectionSwitcher.setupAppearance()
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
        guard sprint != nil else { return }
        switch currentSection {
        case .habits, .targets:
            setupCacheObserver(forSection: currentSection, sprintID: sprint.id)
        case .water: break
        }
    }
    
    private func updateSprintProgress(tasks: [Task]) {
        let progress = CGFloat(tasks.filter { $0.isDone(at: Date()) || $0.isDone }.count) / CGFloat(tasks.count)
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
    
    private func setSwitcherEnabled(_ isEnabled: Bool) {
        self.sectionSwitcher.isEnabled = isEnabled
        self.sectionSwitcher.alpha = isEnabled ? AppTheme.current.style.alpha.enabled : AppTheme.current.style.alpha.disabled
    }
    
}

private extension TodayViewController {
    
    func setupCreateSprintButton() {
        createSprintButton.setTitle("create_sprint".localized, for: .normal)
        createSprintButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        createSprintButton.setTitleColor(.white, for: .normal)
        createSprintButton.layer.cornerRadius = 12
        createSprintButton.clipsToBounds = true
        createSprintButton.isHidden = true
    }
    
}

private extension TodayViewController {
    
    func setupPlaceholder() {
        placeholderView.setup(into: placeholderContainer)
        placeholderView.titleLabel.font = UIFont.avenirNextMedium(18)
        placeholderView.subtitleLabel.font = UIFont.avenirNextRegular(14)
        placeholderContainer.isHidden = true
    }
    
    func showNextSprintPlaceholder(sprintNumber: Int, startDate: Date) {
        placeholderContainer.isHidden = false
        placeholderView.icon = #imageLiteral(resourceName: "calendar")
        placeholderView.title = "next_sprint_is".localized + " \("Sprint".localized) #\(sprintNumber)"
        placeholderView.subtitle = "starts".localized + " " + startDate.asNearestShortDateString.lowercased()
    }
    
    func showCreateSprintPlaceholder() {
        placeholderContainer.isHidden = false
        placeholderView.icon = #imageLiteral(resourceName: "calendar") // TODO: Change icon
        placeholderView.title = "there_is_no_sprints".localized
        placeholderView.subtitle = "do_you_want_to_create_new_sprint".localized
    }
    
    func hidePlaceholder() {
        placeholderContainer.isHidden = true
    }
    
}
