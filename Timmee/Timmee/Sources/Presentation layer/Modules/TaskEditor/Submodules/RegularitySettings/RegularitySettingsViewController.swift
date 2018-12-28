//
//  RegularitySettingsViewController.swift
//  Timmee
//
//  Created by i.kharabet on 28.12.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

protocol RegularitySettingsInput: AnyObject {
    var output: RegularitySettingsOutput? { get set }
    var viewOutput: RegularitySettingsViewOutput? { get set }
    
    func updateParameters(task: Task)
}

protocol RegularitySettingsOutput: AnyObject {
    func regularitySettings(_ module: RegularitySettingsInput,
                            didClearParameter parameter: RegularitySettingsViewController.Parameter)
}

protocol RegularitySettingsViewOutput: AnyObject {
    func regularitySettings(_ viewController: RegularitySettingsViewController,
                            didSelectParameter parameter: RegularitySettingsViewController.Parameter)
}

final class RegularitySettingsViewController: UIViewController, RegularitySettingsInput {
    
    enum Parameter {
        case timeTemplate
        case dueDate
        case dueDateTime
        case dueTime
        case startDate
        case endDate
        case notification
        case repeating
    }
    
    private var parameters: [Parameter] = [] {
        didSet { setupParameterViews() }
    }
    private var parameterViews: [Parameter: UIView] = [:]
    
    @IBOutlet private var parameterModulesContainerView: UIStackView!
    
    weak var output: RegularitySettingsOutput?
    weak var viewOutput: RegularitySettingsViewOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func updateParameters(task: Task) {
        guard self.isViewLoaded else { return }
        
        let parameters = makeParameters(forTask: task)
        if self.parameters != parameters {
            self.parameters = parameters
            setupParameterViews()
        }
        
        updateTimeTemplateView(task: task)
        updateDueDateTimeView(task: task)
        updateStartDateView(task: task)
        updateNotificationView(task: task)
        updateRepeatView(task: task)
        updateEndDateView(task: task)
    }
    
}

// MARK: - Parameter view's actions handlers

private extension RegularitySettingsViewController {
    
    private func onTapToClearParameterButton(parameter: Parameter) {
        output?.regularitySettings(self, didClearParameter: parameter)
    }
    
    private func onTapToParameterView(parameter: Parameter) {
        // Если установлен временной шаблон, то даем выбрать только дату без времени
        if parameter == .dueDateTime, let timeTemplateView = parameterViews[.timeTemplate] as? TaskParameterView, timeTemplateView.isFilled {
            viewOutput?.regularitySettings(self, didSelectParameter: .dueDate)
        } else {
            viewOutput?.regularitySettings(self, didSelectParameter: parameter)
        }
    }
    
}

// MARK: - Parameter views setup

private extension RegularitySettingsViewController {
    
    func setupParameterViews() {
        parameterViews = [:]
        parameterModulesContainerView.arrangedSubviews.forEach {
            parameterModulesContainerView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        parameters.forEach { parameter in
            let parameterView = makeView(forParameter: parameter)
            parameterViews[parameter] = parameterView
            parameterModulesContainerView.addArrangedSubview(parameterView)
        }
    }
    
    func makeParameters(forTask task: Task) -> [Parameter] {
        switch task.repeatKind {
        case .single: return [.timeTemplate, .dueDateTime, .notification]
        case .regular: return [.repeating, .notification, .startDate, .endDate]
        }
    }
    
    func makeView(forParameter parameter: Parameter) -> UIView {
        let parameterView: TaskParameterView
        switch parameter {
        case .timeTemplate:
            parameterView = TaskComplexParameterView.loadedFromNib()
        case .dueDate, .dueTime, .dueDateTime, .startDate, .endDate, .notification, .repeating:
            parameterView = TaskParameterView.loadedFromNib()
        }
        parameterView.setup(withParameter: parameter)
        parameterView.didClear = { [unowned self] in
            self.onTapToClearParameterButton(parameter: parameter)
        }
        parameterView.didTouchedUp = { [unowned self] in
            self.onTapToParameterView(parameter: parameter)
        }
        return parameterView
    }
    
}

// MARK: - Parameter views update

private extension RegularitySettingsViewController {
    
    func updateTimeTemplateView(task: Task) {
        guard let timeTemplateView = parameterViews[.timeTemplate] as? TaskComplexParameterView else { return }
        
        timeTemplateView.text = task.timeTemplate?.title ?? "time_template_placeholder".localized
        
        if let timeTemplate = task.timeTemplate, let time = timeTemplate.time {
            let minutes: String
            if time.minutes < 10 {
                minutes = "\(time.minutes)0"
            } else {
                minutes = "\(time.minutes)"
            }
            timeTemplateView.subtitle = "\(time.hours):\(minutes), " + timeTemplate.notification.title
        } else {
            timeTemplateView.subtitle = nil
        }
        
        timeTemplateView.isFilled = task.timeTemplate != nil
    }
    
    func updateDueDateTimeView(task: Task) {
        guard let dueDateTimeView = parameterViews[.dueDateTime] as? TaskParameterView else { return }
        
        let dueDateTime = task.dueDate
        let isOverdue = UserProperty.highlightOverdueTasks.bool() && (dueDateTime != nil && !(dueDateTime! >= Date()))
        
        dueDateTimeView.text = dueDateTime?.asNearestDateString ?? "due_date".localized
        dueDateTimeView.filledTitleColor = isOverdue ? AppTheme.current.redColor : AppTheme.current.tintColor
        dueDateTimeView.updateTitleColor()
        dueDateTimeView.isFilled = dueDateTime != nil
    }
    
    func updateStartDateView(task: Task) {
        guard let startDateView = parameterViews[.startDate] as? TaskParameterView else { return }
        
        let startDate = task.dueDate
        
        startDateView.text = startDate?.asNearestShortDateString ?? "start_date".localized
        startDateView.filledTitleColor = AppTheme.current.tintColor
        startDateView.updateTitleColor()
        startDateView.isFilled = startDate != nil
        startDateView.canClear = false
    }
    
    func updateNotificationView(task: Task) {
        guard let reminderView = parameterViews[.notification] as? TaskParameterView else { return }
        
        let notification: TaskReminderSelectedNotification
        if let notificationTime = task.notificationTime {
            notification = .time(notificationTime.0, notificationTime.1)
        } else if let notificationDate = task.notificationDate {
            notification = .date(notificationDate)
        } else {
            notification = .mask(task.notification)
        }
        
        switch notification {
        case let .mask(notificationMask):
            reminderView.text = notificationMask.title
            reminderView.isFilled = notificationMask != .doNotNotify
        case let .date(notificationDate):
            reminderView.text = notificationDate.asNearestDateString
            reminderView.isFilled = true
        case let .time(hours, minutes):
            let minutesString = minutes < 10 ? "0\(minutes)" : "\(minutes)"
            reminderView.text = "\(hours):\(minutesString)" // TODO
            reminderView.isFilled = true
        }
    }
    
    func updateRepeatView(task: Task) {
        guard let repeatView = parameterViews[.repeating] as? TaskParameterView else { return }
        
        let `repeat` = task.repeating
        
        repeatView.text = `repeat`.fullLocalizedString
        repeatView.isFilled = !`repeat`.type.isNever
        repeatView.canClear = false
    }
    
    func updateEndDateView(task: Task) {
        guard let repeatEndingDateView = parameterViews[.endDate] as? TaskParameterView else { return }
        
        let endDate = task.repeatEndingDate
        
        repeatEndingDateView.text = endDate?.asNearestShortDateString ?? "repeat_ending_date".localized
        repeatEndingDateView.isFilled = endDate != nil
    }
    
}
