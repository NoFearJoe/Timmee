//
//  TodayViewController.swift
//  HabitsTodayExtension
//
//  Created by i.kharabet on 18.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import NotificationCenter
import TasksKit

class TodayExtensionViewController: UIViewController, NCWidgetProviding, SprintInteractorTrait, TargetAndHabitInteractorTrait {
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var messageLabel: UILabel!
    
    private var sprint: Sprint?
    private var habits: [Task] = []
    
    let sprintsService = ServicesAssembly.shared.sprintsService
    let tasksService = ServicesAssembly.shared.tasksService
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.text = "no_habits_for_today".localized
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        reloadHabits()
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        switch activeDisplayMode {
        case .compact: preferredContentSize = CGSize(width: maxSize.width, height: maxSize.height)
        case .expanded:
            let height = max(132, 68 * habits.count)
            preferredContentSize = CGSize(width: maxSize.width, height: min(CGFloat(height), maxSize.height))
        }
    }
    
    private func reloadHabits() {
        guard let sprint = getCurrentSprint() else { return }
        
        self.sprint = sprint
        
        habits = tasksService.fetchTasks(listID: sprint.id).filter { $0.kind == "habit" && !$0.isDone(at: Date.now) }
        tableView.reloadData()
        
        messageLabel.isHidden = !habits.isEmpty
    }
    
}

extension TodayExtensionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return habits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodayExtensionHabitCell", for: indexPath) as! TodayExtensionHabitCell
        if let habit = habits.item(at: indexPath.row) {
            cell.configure(habit: habit)
            cell.onChangeCheckedState = { [unowned self] isChecked in
                habit.setDone(isChecked, at: Date.now)
                guard let sprint = self.sprint else { return }
                self.saveTask(habit, listID: sprint.id, completion: { [weak self] _ in
                    self?.reloadHabits()
                })
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
}
