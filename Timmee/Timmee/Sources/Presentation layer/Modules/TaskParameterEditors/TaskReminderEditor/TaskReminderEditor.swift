//
//  TaskReminderEditor.swift
//  Timmee
//
//  Created by Ilya Kharabet on 19.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

protocol TaskReminderEditorInput: class {
    func setNotificationMask(_ notificationMask: NotificationMask)
}

protocol TaskReminderEditorOutput: class {
    func didSelectNotificationMask(_ notificationMask: NotificationMask)
}

final class TaskReminderEditor: UITableViewController {

    weak var output: TaskReminderEditorOutput?
    
    var selectedMask: NotificationMask = .doNotNotify {
        didSet {
            if selectedMask != oldValue {
                output?.didSelectNotificationMask(selectedMask)
                tableView.reloadData()
            }
        }
    }
    
    static fileprivate let rowHeight: CGFloat = 44
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.backgroundColor = .clear
        tableView.separatorColor = AppTheme.current.panelColor
    }

}

extension TaskReminderEditor: TaskReminderEditorInput {

    func setNotificationMask(_ notificationMask: NotificationMask) {
        self.selectedMask = notificationMask
    }

}

extension TaskReminderEditor {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NotificationMask.all.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskReminderCell", for: indexPath) as! TaskReminderCell
        
        if let mask = NotificationMask.all.item(at: indexPath.row) {
            cell.setNotificationMask(mask)
            cell.setMaskSelected(mask == selectedMask)
        }
        
        cell.setupAppearance()
        
        return cell
    }

}

extension TaskReminderEditor {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let mask = NotificationMask.all.item(at: indexPath.row) {
            selectedMask = mask
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TaskReminderEditor.rowHeight
    }

}

extension TaskReminderEditor: TaskParameterEditorInput {

    var requiredHeight: CGFloat {
        return CGFloat(NotificationMask.all.count) * TaskReminderEditor.rowHeight
    }

}


final class TaskReminderCell: UITableViewCell {

    @IBOutlet fileprivate weak var iconView: UIImageView!
    @IBOutlet fileprivate weak var titleView: UILabel!
    @IBOutlet fileprivate weak var selectedMaskIndicator: UIView!
    
    func setNotificationMask(_ mask: NotificationMask) {
        titleView?.text = mask.title
//        imageView?.image = mask.icon TODO
    }
    
    func setMaskSelected(_ isSelected: Bool) {
        selectedMaskIndicator.isHidden = !isSelected
    }
    
    func setupAppearance() {
        titleView.textColor = AppTheme.current.tintColor
        selectedMaskIndicator.backgroundColor = AppTheme.current.blueColor
    }

}
