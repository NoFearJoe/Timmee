//
//  TaskReminderEditor.swift
//  Timmee
//
//  Created by Ilya Kharabet on 19.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

enum TaskReminderSelectedNotification {
    case mask(NotificationMask)
    case date(Date)
    case time(Int, Int)
}

extension TaskReminderSelectedNotification: Equatable {
    static func == (lhs: TaskReminderSelectedNotification, rhs: TaskReminderSelectedNotification) -> Bool {
        switch (lhs, rhs) {
        case let (.mask(mask1), .mask(mask2)): return mask1 == mask2
        case let (.date(date1), .date(date2)): return date1.compare(date2) == .orderedSame
        case let (.time(hours1, minutes1), .time(hours2, minutes2)): return hours1 == hours2 && minutes1 == minutes2
        default: return false
        }
    }
}

protocol TaskReminderEditorInput: class {
    func setNotification(_ notification: TaskReminderSelectedNotification)
    func setNotificationDatePickerVisible(_ isVisible: Bool)
    func setNotificationTimePickerVisible(_ isVisible: Bool)
    func setNotificationMasksVisible(_ isVisible: Bool)
}

protocol TaskReminderEditorOutput: class {
    func didSelectNotification(_ notification: TaskReminderSelectedNotification)
}

protocol TaskReminderEditorTransitionOutput: class {
    func didAskToShowNotificationDatePicker(completion: @escaping (CalendarWithTimeViewController) -> Void)
    func didAskToShowNotificationTimePicker(completion: @escaping (TimePicker) -> Void)
}

final class TaskReminderEditor: UITableViewController {

    weak var output: TaskReminderEditorOutput?
    weak var container: TaskParameterEditorOutput?
    weak var transitionOutput: TaskReminderEditorTransitionOutput?
    
    var selectedNotification: TaskReminderSelectedNotification = .mask(.doNotNotify) {
        didSet {
            guard selectedNotification != oldValue else { return }
            output?.didSelectNotification(selectedNotification)
            tableView.reloadData()
        }
    }
    
    private var notificationTime: (Int, Int)?
    
    var isNotificationMasksVisible: Bool = true
    var isNotificationDatePickerVisible: Bool = true
    var isNotificationTimePickerVisible: Bool = false
    
    static private let rowHeight: CGFloat = 44
    
    private var sectionsCount: Int {
        return 1
            + (isNotificationDatePickerVisible ? 1 : 0)
            + (isNotificationTimePickerVisible ? 1 : 0)
    }
    
    private var rowsCount: Int {
        return (isNotificationMasksVisible ? NotificationMask.all.count : 1)
            + (isNotificationDatePickerVisible ? 1 : 0)
            + (isNotificationTimePickerVisible ? 1 : 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.backgroundColor = .clear
        tableView.separatorColor = AppTheme.current.panelColor
    }

}

extension TaskReminderEditor: TaskReminderEditorInput {

    func setNotification(_ notification: TaskReminderSelectedNotification) {
        selectedNotification = notification
        if case .time(let hours, let minutes) = notification {
            notificationTime = (hours, minutes)
        }
    }
    
    func setNotificationDatePickerVisible(_ isVisible: Bool) {
        isNotificationDatePickerVisible = isVisible
    }
    
    func setNotificationTimePickerVisible(_ isVisible: Bool) {
        isNotificationTimePickerVisible = isVisible
    }
    
    func setNotificationMasksVisible(_ isVisible: Bool) {
        isNotificationMasksVisible = isVisible
    }

}

extension TaskReminderEditor {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsCount
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return isNotificationMasksVisible ? NotificationMask.all.count : 1
        case 1 where isNotificationDatePickerVisible: return 1
        case 1 where !isNotificationDatePickerVisible: fallthrough
        case 2 where isNotificationTimePickerVisible: return 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaskReminderCell", for: indexPath) as! TaskReminderCell
            
            if let mask = NotificationMask.all.item(at: indexPath.row) {
                cell.setNotificationMask(mask)
                if case .mask(let notificationMask) = selectedNotification {
                    cell.setSelected(mask == notificationMask)
                } else {
                    cell.setSelected(false)
                }
            }
            
            cell.setupAppearance()
            
            return cell
        case 1 where isNotificationDatePickerVisible:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaskReminderDateCell", for: indexPath) as! TaskReminderDateCell
            
            if case .date(let notificationDate) = selectedNotification {
                cell.setNotificationDateString(notificationDate.asNearestDateString)
                cell.setSelected(true)
            } else {
                cell.setNotificationDateString("choose_notification_date".localized)
                cell.setSelected(false)
            }
            
            cell.setupAppearance()
            
            return cell
        case 1 where !isNotificationDatePickerVisible: fallthrough
        case 2 where isNotificationTimePickerVisible:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaskReminderDateCell", for: indexPath) as! TaskReminderDateCell
            
            if case .time(let time) = selectedNotification {
                let minutesString = time.1 < 10 ? "0\(time.1)" : "\(time.1)"
                cell.setNotificationDateString("\(time.0):\(minutesString)")
                cell.setSelected(true)
            } else {
                cell.setNotificationDateString("choose_notification_time".localized)
                cell.setSelected(false)
            }
            
            cell.setupAppearance()
            
            return cell
        default:
            return UITableViewCell()
        }
    }

}

extension TaskReminderEditor {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            guard let mask = NotificationMask.all.item(at: indexPath.row) else { return }
            selectedNotification = .mask(mask)
        case 1 where isNotificationDatePickerVisible:
            transitionOutput?.didAskToShowNotificationDatePicker { [unowned self] dueDateTimeEditor in
                dueDateTimeEditor.onSelectDate = { [unowned self] date in
                    guard let date = date else { return }
                    self.selectedNotification = .date(date)
                }
                if case .date(let notificationDate) = self.selectedNotification {
                    dueDateTimeEditor.configure(selectedDate: notificationDate, minimumDate: nil)
                } else {
                    dueDateTimeEditor.configure(selectedDate: Date(), minimumDate: nil)
                }
            }
        case 1 where !isNotificationDatePickerVisible: fallthrough
        case 2 where isNotificationTimePickerVisible:
            transitionOutput?.didAskToShowNotificationTimePicker { [unowned self] dueTimePicker in
                dueTimePicker.output = self
                if case .time(let notificationTime) = self.selectedNotification {
                    dueTimePicker.setHours(notificationTime.0)
                    dueTimePicker.setMinutes(notificationTime.1)
                } else {
                    dueTimePicker.setHours(Date().hours)
                    dueTimePicker.setMinutes(Date().minutes)
                }
            }
        default: return
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TaskReminderEditor.rowHeight
    }

}

extension TaskReminderEditor: TimePickerOutput {
    
    func didChangeHours(to hours: Int) {
        notificationTime = (hours, notificationTime?.1 ?? 0)
        selectedNotification = .time(hours, notificationTime?.1 ?? 0)
    }
    
    func didChangeMinutes(to minutes: Int) {
        notificationTime = (notificationTime?.0 ?? 0, minutes)
        selectedNotification = .time(notificationTime?.0 ?? 0, minutes)
    }
    
}

extension TaskReminderEditor: TaskParameterEditorInput {

    var requiredHeight: CGFloat {
        return CGFloat(rowsCount) * TaskReminderEditor.rowHeight
    }

}


final class TaskReminderCell: UITableViewCell {

    @IBOutlet fileprivate weak var titleView: UILabel!
    @IBOutlet fileprivate weak var selectedMaskIndicator: UIView!
    
    func setNotificationMask(_ mask: NotificationMask) {
        titleView?.text = mask.title
    }
    
    func setSelected(_ isSelected: Bool) {
        selectedMaskIndicator.isHidden = !isSelected
    }
    
    func setupAppearance() {
        titleView.textColor = AppTheme.current.tintColor
        selectedMaskIndicator.backgroundColor = AppTheme.current.blueColor
    }

}

final class TaskReminderDateCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var titleView: UILabel!
    @IBOutlet fileprivate weak var selectedMaskIndicator: UIView!
    
    func setNotificationDateString(_ dateString: String) {
        titleView?.text = dateString
    }
    
    func setSelected(_ isSelected: Bool) {
        selectedMaskIndicator.isHidden = !isSelected
    }
    
    func setupAppearance() {
        titleView.textColor = AppTheme.current.tintColor
        selectedMaskIndicator.backgroundColor = AppTheme.current.blueColor
    }
    
}
