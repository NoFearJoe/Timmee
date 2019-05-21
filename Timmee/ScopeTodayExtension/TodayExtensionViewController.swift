//
//  TodayExtensionViewController.swift
//  ScopeTodayExtension
//
//  Created by i.kharabet on 20/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import NotificationCenter
import TasksKit

class TodayExtensionViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var messageLabel: UILabel!
    
    private let tasksService = ServicesAssembly.shared.tasksService
    
    private var tasks: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.text = "no_tasks_for_today".localized
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        reloadTasks()
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        switch activeDisplayMode {
        case .compact:
            preferredContentSize = CGSize(width: maxSize.width, height: maxSize.height)
        case .expanded:
            let height = max(132, 68 * tasks.count)
            preferredContentSize = CGSize(width: maxSize.width, height: min(CGFloat(height), maxSize.height))
        @unknown default:
            preferredContentSize = CGSize(width: maxSize.width, height: maxSize.height)
        }
    }
    
    private func reloadTasks() {
        tasks = tasksService.fetchTasks(smartListID: SmartListType.today.id, predicate: .notCompleted(date: Date()))
        tasks = Array(tasks.prefix(5))
        tableView.reloadData()
        
        messageLabel.isHidden = !tasks.isEmpty
    }
    
}

extension TodayExtensionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TodayExtensionTaskCell
        if let task = tasks.item(at: indexPath.row) {
            cell.configure(task: task)
            cell.onChangeCheckedState = { [unowned self] isChecked in
                task.setDone(isChecked, at: Date())
                self.tasksService.updateTask(task, completion: { [weak self] _ in
                    self?.reloadTasks()
                })
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
}
