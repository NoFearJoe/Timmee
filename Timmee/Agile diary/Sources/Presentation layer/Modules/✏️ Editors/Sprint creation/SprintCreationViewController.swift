//
//  SprintCreationViewController.swift
//  Agile diary
//
//  Created by Илья Харабет on 30/05/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import UIComponents

final class SprintCreationViewController: BaseViewController, SprintInteractorTrait {
    
    let sprintsService = ServicesAssembly.shared.sprintsService
    let sprintSchedulerService = SprintSchedulerService()
    
    private let contentContainer = StackViewController()
    
    private let headerView = DefaultLargeHeaderView()
    
    private let startDatePickerContainer = SectionContainer()
    private let startDatePicker = ViewControllersFactory.dueDatePicker
    private let sprintDurationPickerContainer = SectionContainer()
    private let sprintDurationPicker = ViewControllersFactory.sprintDurationPicker
    private let sprintNotificationsPickerContainer = SectionContainer()
    private let sprintNotificationsCheckbox = Checkbox()
    private let sprintNotificationsPicker = ViewControllersFactory.sprintNotificationTimePicker
    
    private let createButton = AddButton()
    
    private var sprint: Sprint!
    private let isNewSprint: Bool
    private let canBeClosed: Bool
    
    init(sprint: Sprint?, canBeClosed: Bool = true) {
        self.isNewSprint = sprint == nil
        self.canBeClosed = canBeClosed
        
        super.init(nibName: nil, bundle: nil)
        
        self.sprint = sprint ?? createNewSprint()
        
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func refresh() {
        super.refresh()
                
        if sprint.startDate.compare(Date.now.startOfDay) == .orderedAscending, isNewSprint {
            sprint.startDate = Date.now.startOfDay
            sprint.endDate = Date.now.endOfDay + sprint.duration.asWeeks
        }
        
        updateUI()
    }
    
    override func prepare() {
        super.prepare()
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        
        startDatePickerContainer.setupAppearance()
        sprintDurationPickerContainer.setupAppearance()
        sprintNotificationsPickerContainer.setupAppearance()
        createButton.setupAppearance()
    }
    
    @objc private func onTapCreateButton() {
        let saveSprintThanClose = { [weak self] in
            guard let self = self else { return }
            
            self.view.isUserInteractionEnabled = false
            self.sprintsService.createOrUpdateSprint(self.sprint) { [weak self] success in
                self?.view.isUserInteractionEnabled = true
                
                if success {
                    self?.close()
                } else {
                    // TODO: Show alert
                }
            }
        }
        
        let scheduleAndSaveSprintThanClose = { [weak self] in
            guard let self = self else { return }
            
            self.sprintSchedulerService.scheduleSprint(self.sprint)
            saveSprintThanClose()
        }
        
        NotificationsConfigurator.getNotificationsPermissionStatus { isAuthorized in
            if isAuthorized {
                scheduleAndSaveSprintThanClose()
            } else {
                NotificationsConfigurator.registerForLocalNotifications(application: UIApplication.shared) { isAuthorized in
                    if isAuthorized {
                        scheduleAndSaveSprintThanClose()
                    } else {
                        saveSprintThanClose()
                    }
                }
            }
        }
    }
    
    private func close() {
        if canBeClosed {
            dismiss(animated: true, completion: nil)
        } else {
            AppWindowRouter.shared.show(screen: ViewControllersFactory.today)
        }
    }
    
}

extension SprintCreationViewController: DueDatePickerOutput {
    
    func didChangeDueDate(to date: Date) {
        sprint.startDate = date
        sprint.endDate = date.endOfDay + sprint.duration.asWeeks
        
        updateHeaderSubtitle()
    }
    
}

extension SprintCreationViewController: SprintDurationPickerDelegate {
    
    func sprintDurationPicker(_ picker: SprintDurationPicker, didSelectSprintDuration duration: Int) {
        sprint.duration = duration
        sprint.endDate = sprint.startDate.endOfDay + sprint.duration.asWeeks
        
        updateHeaderSubtitle()
    }
    
}

extension SprintCreationViewController: SprintNotificationTimePickerOutput {
    
    func didChangeNotificationsDays(_ days: [DayUnit]) {
        sprint.notifications.days = days
        
        updateHeaderSubtitle()
    }
    
    func didChangeNotificationsTime(_ time: (Int, Int)) {
        sprint.notifications.time = time
        
        updateHeaderSubtitle()
    }
    
}

private extension SprintCreationViewController {
 
    func updateUI() {
        headerView.configure(
            title: sprint.title,
            subtitle: makeHeaderSubtitle(
                startDate: sprint.startDate,
                duration: sprint.duration,
                sprintNotifications: sprint.notifications
            ),
            onTapLeftButton: modalPresentationStyle != .pageSheet && canBeClosed ? { [unowned self] in self.close() } : nil,
            onTapRightButton: nil
        )
        
        startDatePicker.minimumAvailableDate = sprint.startDate
        startDatePicker.setDueDate(sprint.startDate)
        
        sprintDurationPicker.setSprintDuration(sprint.duration)
        
        sprintNotificationsCheckbox.isChecked = sprint.notifications.isEnabled
        sprintNotificationsPickerContainer.contentContainer.isHidden = !sprint.notifications.isEnabled
        sprintNotificationsPicker.setNotificationsDays(sprint.notifications.days ?? [])
        sprintNotificationsPicker.setNotificationsTime(sprint.notifications.time ?? (0, 0))
    }
    
}

private extension SprintCreationViewController {
    
    func setupViews() {
        view.addSubview(headerView)
        [headerView.leading(), headerView.trailing(), headerView.top()].toSuperview()
        
        addChild(contentContainer)
        view.addSubview(contentContainer.view)
        [contentContainer.view.leading(), contentContainer.view.trailing(), contentContainer.view.bottom()].toSuperview()
        contentContainer.view.topToBottom().to(headerView, addTo: view)
        contentContainer.didMove(toParent: self)
        
        contentContainer.stackView.layoutMargins = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15)
        contentContainer.stackView.isLayoutMarginsRelativeArrangement = true
        
        contentContainer.stackView.spacing = 20
        contentContainer.scrollView.contentInset.bottom = 52 + 12 + 16
        
        contentContainer.setChild(startDatePickerContainer, at: 0)
        contentContainer.setChild(sprintDurationPickerContainer, at: 1)
        contentContainer.setChild(sprintNotificationsPickerContainer, at: 2)
        
        startDatePicker.output = self
        addChild(startDatePicker)
        startDatePickerContainer.configure(title: "sprint_start_date".localized, content: startDatePicker.view)
        startDatePicker.didMove(toParent: self)
        
        sprintDurationPicker.delegate = self
        addChild(sprintDurationPicker)
        sprintDurationPickerContainer.configure(title: "sprint_duration_picker_title".localized, content: sprintDurationPicker.view)
        sprintDurationPicker.didMove(toParent: self)
        
        sprintNotificationsPicker.output = self
        addChild(sprintNotificationsPicker)
        sprintNotificationsPickerContainer.configure(
            title: "sprint_notifications".localized,
            content: sprintNotificationsPicker.view,
            actionView: sprintNotificationsCheckbox,
            disclaimer: "sprint_notifications_disclaimer".localized
        )
        sprintNotificationsPickerContainer.contentContainer.isHidden = true
        setupSprintNotificationsCheckbox()
        sprintNotificationsPicker.didMove(toParent: self)
        
        view.addSubview(createButton)
        createButton.layer.cornerRadius = 8
        createButton.clipsToBounds = true
        if isNewSprint {
            createButton.setTitle("create_sprint".localized, for: .normal)
        } else {
            createButton.setTitle("save".localized, for: .normal)
        }
        createButton.addTarget(self, action: #selector(onTapCreateButton), for: .touchUpInside)
        createButton.height(52)
        [createButton.leading(15), createButton.trailing(15)].toSuperview()
        if #available(iOS 11.0, *) {
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
        } else {
            createButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8).isActive = true
        }
    }
    
    func setupSprintNotificationsCheckbox() {
        sprintNotificationsCheckbox.width(32)
        sprintNotificationsCheckbox.height(32)
        sprintNotificationsCheckbox.backgroundColor = .clear
        sprintNotificationsCheckbox.didChangeCkeckedState = { [unowned self] isChecked in
            self.sprint.notifications.isEnabled = isChecked
            
            self.updateUI()
        }
    }
    
}

private extension SprintCreationViewController {
    
    func updateHeaderSubtitle() {
        headerView.subtitleLabel.attributedText = makeHeaderSubtitle(
            startDate: sprint.startDate,
            duration: sprint.duration,
            sprintNotifications: sprint.notifications
        )
    }
    
    func makeHeaderSubtitle(startDate: Date, duration: Int, sprintNotifications: Sprint.Notifications) -> NSAttributedString {
        let resultString = NSMutableAttributedString(string: "starts".localized + " ",
                                                     attributes: [.foregroundColor: AppTheme.current.colors.activeElementColor])
        
        let dateString = NSAttributedString(string: startDate.asNearestShortDateString.lowercased(),
                                            attributes: [.foregroundColor: AppTheme.current.colors.mainElementColor])
        resultString.append(dateString)
        
        let durationString = NSAttributedString(string: ", \(duration) " + "n_weeks".localized(with: duration),
                                                attributes: [.foregroundColor: AppTheme.current.colors.activeElementColor])
        resultString.append(durationString)
        
        if sprintNotifications.isEnabled, let days = sprintNotifications.days, let time = sprintNotifications.time {
            resultString.append(NSAttributedString(string: ", " + "reminder".localized.lowercased() + " ",
                                                   attributes: [.foregroundColor: AppTheme.current.colors.activeElementColor]))
            let repeating = RepeatMask(type: .on(.custom(Set(days))))
            resultString.append(NSAttributedString(string: repeating.localized.lowercased(),
                                                   attributes: [.foregroundColor: AppTheme.current.colors.mainElementColor]))
            resultString.append(NSAttributedString(string: " " + "at".localized + " ",
                                                   attributes: [.foregroundColor: AppTheme.current.colors.activeElementColor]))
            let minutesString = time.1 < 10 ? "0\(time.1)" : "\(time.1)"
            resultString.append(NSAttributedString(string: "\(time.0):" + minutesString,
                                                   attributes: [.foregroundColor: AppTheme.current.colors.mainElementColor]))
        } else {
            resultString.append(NSAttributedString(string: ", " + "notifications_are_disabled".localized.lowercased(),
                                                   attributes: [.foregroundColor: AppTheme.current.colors.activeElementColor]))
        }
        
        return resultString
    }
    
}
