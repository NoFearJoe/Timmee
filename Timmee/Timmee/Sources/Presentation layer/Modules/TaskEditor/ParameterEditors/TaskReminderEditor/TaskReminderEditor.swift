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
}

extension TaskReminderSelectedNotification: Equatable {
    static func == (lhs: TaskReminderSelectedNotification, rhs: TaskReminderSelectedNotification) -> Bool {
        switch (lhs, rhs) {
        case let (.mask(mask1), .mask(mask2)): return mask1 == mask2
        case let (.date(date1), .date(date2)): return date1.compare(date2) == .orderedSame
        default: return false
        }
    }
}

protocol TaskReminderEditorInput: class {
    func setNotification(_ notification: TaskReminderSelectedNotification)
    func setNotificationDatePickerVisible(_ isVisible: Bool)
    func setNotificationMasksVisible(_ isVisible: Bool)
}

protocol TaskReminderEditorOutput: class {
    func didSelectNotification(_ notification: TaskReminderSelectedNotification)
}

protocol TaskReminderEditorTransitionOutput: class {
    func didAskToShowNotificationDatePicker(completion: @escaping (TaskDueDateTimeEditor) -> Void)
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
    
    var isNotificationMasksVisible: Bool = true
    var isNotificationDatePickerVisible: Bool = true
    
    static private let rowHeight: CGFloat = 44
    
    private var rowsCount: Int {
        return (isNotificationMasksVisible ? NotificationMask.all.count : 1) + (isNotificationDatePickerVisible ? 1 : 0)
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
    }
    
    func setNotificationDatePickerVisible(_ isVisible: Bool) {
        isNotificationDatePickerVisible = isVisible
    }
    
    func setNotificationMasksVisible(_ isVisible: Bool) {
        isNotificationMasksVisible = isVisible
    }

}

extension TaskReminderEditor {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == rowsCount - 1 {
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
        } else {
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
        }
    }

}

extension TaskReminderEditor {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == rowsCount - 1 {
            transitionOutput?.didAskToShowNotificationDatePicker { [unowned self] dueDateTimeEditor in
                dueDateTimeEditor.output = self
                if case .date(let notificationDate) = self.selectedNotification {
                    dueDateTimeEditor.setDueDate(notificationDate)
                } else {
                    dueDateTimeEditor.setDueDate(Date())
                }
            }
        } else {
            if let mask = NotificationMask.all.item(at: indexPath.row) {
                selectedNotification = .mask(mask)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TaskReminderEditor.rowHeight
    }

}

extension TaskReminderEditor: TaskDueDateTimeEditorOutput {
    
    func didSelectDueDate(_ dueDate: Date) {
        selectedNotification = .date(dueDate)
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
