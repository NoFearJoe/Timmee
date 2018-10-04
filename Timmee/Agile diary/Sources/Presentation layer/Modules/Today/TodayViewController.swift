//
//  TodayViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 10.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import UIComponents

protocol TodayViewSectionProgressListener: class {
    func didChangeProgress(for section: SprintSection, to progress: CGFloat)
}

final class TodayViewController: BaseViewController, SprintInteractorTrait, AlertInput {
    
    @IBOutlet private var headerView: LargeHeaderView!
    @IBOutlet private var sectionSwitcher: Switcher!
    @IBOutlet private var progressBar: ProgressBar!
    @IBOutlet private var createSprintButton: UIButton!
    @IBOutlet private var backgroundImageView: UIImageView!
    
    @IBOutlet private var contentViewContainer: UIView!
    @IBOutlet private var waterControlViewContainer: UIView!
    
    @IBOutlet private var placeholderContainer: UIView!
    private lazy var placeholderView = PlaceholderView.loadedFromNib()
    
    private var contentViewController: TodayContentViewController!
    private var waterControlViewController: WaterControlViewController!
    
    private var currentSection = SprintSection.habits
    
    private var cacheObserver: CacheObserver<Task>?
    
    var sprint: Sprint! {
        didSet {
            hidePlaceholder()
            contentViewController.sprintID = sprint.id
            waterControlViewController.sprint = sprint
            updateHeaderSubtitle(sprint: sprint)
        }
    }
    
    let sprintsService = ServicesAssembly.shared.listsService
    
    override func prepare() {
        super.prepare()
        
        headerView.titleLabel.text = "today".localized
        headerView.subtitleLabel.text = nil
        if ProVersionPurchase.shared.isPurchased() {
            sectionSwitcher.items = [SprintSection.habits.title, SprintSection.targets.title, SprintSection.water.title]
        } else {
            sectionSwitcher.items = [SprintSection.habits.title, SprintSection.targets.title]
        }
        sectionSwitcher.selectedItemIndex = 0
        sectionSwitcher.addTarget(self, action: #selector(onSwitchSection), for: .touchUpInside)
        progressBar.setProgress(0)
        contentViewContainer.isHidden = false
        waterControlViewContainer.isHidden = true
        createSprintButton.isHidden = true
        
        setupPlaceholder()
    }
    
    override func refresh() {
        super.refresh()
        
        if ProVersionPurchase.shared.isPurchased() {
            backgroundImageView.image = BackgroundImage.current.image
        }
        loadSprint()
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        
        view.backgroundColor = AppTheme.current.colors.middlegroundColor
        headerView.titleLabel.textColor = AppTheme.current.colors.activeElementColor
        headerView.subtitleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        headerView.leftButton?.tintColor = AppTheme.current.colors.activeElementColor
        headerView.rightButton?.tintColor = AppTheme.current.colors.mainElementColor
        progressBar.fillColor = AppTheme.current.colors.mainElementColor
        headerView.backgroundColor = AppTheme.current.colors.foregroundColor
        sectionSwitcher.setupAppearance()
        setupPlaceholderAppearance()
        setupCreateSprintButton()
        sprint.flatMap { updateHeaderSubtitle(sprint: $0) }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SprintContent" {
            contentViewController = segue.destination as? TodayContentViewController
            contentViewController.section = currentSection
            contentViewController.transitionHandler = self
            contentViewController.progressListener = self
        } else if segue.identifier == "WaterControl" {
            waterControlViewController = segue.destination as? WaterControlViewController
            waterControlViewController.progressListener = self
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
        guard sprint != nil else { return }
        switch currentSection {
        case .habits, .targets:
            setSectionContainersVisible(content: true, water: false)
            contentViewController.section = currentSection
        case .water:
            setSectionContainersVisible(content: false, water: true)
        }
    }   
    
    private func updateHeaderSubtitle(sprint: Sprint) {
        let daysRemaining = Date.now.days(before: sprint.endDate)
        let subtitle = NSMutableAttributedString()
        subtitle.append(NSAttributedString(string: "Sprint".localized, attributes: [.foregroundColor: AppTheme.current.colors.inactiveElementColor]))
        subtitle.append(NSAttributedString(string: " #\(sprint.sortPosition)", attributes: [.foregroundColor: AppTheme.current.colors.mainElementColor]))
        
        let remainingDaysString = NSMutableAttributedString(string: ", " + "remains_n_days".localized(with: daysRemaining),
                                                            attributes: [.foregroundColor: AppTheme.current.colors.inactiveElementColor])
        if let daysCountRange = remainingDaysString.string.range(of: "\(daysRemaining)")?.nsRange {
            remainingDaysString.setAttributes([.foregroundColor: AppTheme.current.colors.mainElementColor], range: daysCountRange)
        }
        subtitle.append(remainingDaysString)
        headerView.subtitleLabel.attributedText = subtitle
    }
    
    private func setSwitcherEnabled(_ isEnabled: Bool) {
        sectionSwitcher.isEnabled = isEnabled
        sectionSwitcher.alpha = isEnabled ? AppTheme.current.style.alpha.enabled : AppTheme.current.style.alpha.disabled
        sectionSwitcher.isHidden = !isEnabled
    }
    
    private func setSectionContainersVisible(content: Bool, water: Bool) {
        contentViewController.performAppearanceTransition(isAppearing: content) { contentViewContainer.isHidden = !content }
        waterControlViewController.performAppearanceTransition(isAppearing: water) { waterControlViewContainer.isHidden = !water }
    }
    
}

private extension TodayViewController {
    
    func loadSprint() {
        if let currentSprint = getCurrentSprint() {
            createSprintButton.isHidden = true
            setSwitcherEnabled(true)
            sprint = currentSprint
        } else if let nextSprint = getNextSprint() {
            createSprintButton.isHidden = true
            setSwitcherEnabled(false)
            headerView.subtitleLabel.text = "next_sprint_starts".localized + " " + nextSprint.creationDate.asNearestShortDateString.lowercased()
            showNextSprintPlaceholder(sprintNumber: nextSprint.sortPosition, startDate: nextSprint.creationDate)
            setSectionContainersVisible(content: false, water: false)
        } else {
            createSprintButton.isHidden = false
            setSwitcherEnabled(false)
            headerView.subtitleLabel.text = nil
            showCreateSprintPlaceholder()
            setSectionContainersVisible(content: false, water: false)
        }
    }
    
}

extension TodayViewController: TodayViewSectionProgressListener {
    
    func didChangeProgress(for section: SprintSection, to progress: CGFloat) {
        guard section == currentSection else { return }
        progressBar.setProgress(progress, animated: true)
    }
    
}

private extension TodayViewController {
    
    func setupCreateSprintButton() {
        createSprintButton.setTitle("create_sprint".localized, for: .normal)
        createSprintButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        createSprintButton.setTitleColor(.white, for: .normal)
        createSprintButton.layer.cornerRadius = 12
        createSprintButton.clipsToBounds = true
    }
    
}

private extension TodayViewController {
    
    func setupPlaceholder() {
        placeholderView.setup(into: placeholderContainer)
        placeholderContainer.isHidden = true
    }
    
    func setupPlaceholderAppearance() {
        placeholderView.backgroundColor = .clear
        placeholderView.titleLabel.font = UIFont.avenirNextMedium(18)
        placeholderView.titleLabel.textColor = AppTheme.current.textColorForTodayLabelsOnBackground
        placeholderView.subtitleLabel.font = UIFont.avenirNextRegular(14)
        placeholderView.subtitleLabel.textColor = AppTheme.current.textColorForTodayLabelsOnBackground
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
