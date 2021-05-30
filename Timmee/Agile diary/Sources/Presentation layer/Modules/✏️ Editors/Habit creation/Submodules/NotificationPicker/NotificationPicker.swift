//
//  NotificationPicker.swift
//  Agile diary
//
//  Created by Илья Харабет on 30.05.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit
import UIComponents

final class NotificationPicker: UIViewController {
    
    var selectedNotification: Habit.Notification {
        switch selectedIndexPath.section {
        case 1: return .before(section2Models[selectedIndexPath.row])
        case 2: return section3Model.map { Habit.Notification.at($0) } ?? .none
        default: return .none
        }
    }
    
    var onChangeHeight: ((CGFloat) -> Void)?
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private let section1Model = Habit.Notification.none
    private let section2Models: [Habit.Notification.Before] = [.zero, .ten, .thirty, .hour]
    private var section3Model: Time?
    
    private var selectedIndexPath = IndexPath(row: 0, section: 0)
    
    private let isTimeSet: Bool
    
    init(notification: Habit.Notification?, isTimeSet: Bool) {
        self.isTimeSet = isTimeSet
        
        switch notification {
        case .none?, nil:
            section3Model = nil
            selectedIndexPath = IndexPath(row: 0, section: 0)
        case let .at(time):
            section3Model = time
            selectedIndexPath = IndexPath(row: 0, section: 2)
        case let .before(minutes):
            section3Model = nil
            selectedIndexPath = IndexPath(row: section2Models.index(of: minutes) ?? 0, section: 1)
        }
        
        super.init(nibName: nil, bundle: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        tableView.isScrollEnabled = false
        tableView.delaysContentTouches = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = C.cellHeight
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(TimeCell.self, forCellReuseIdentifier: TimeCell.identifier)
        view.addSubview(tableView)
        tableView.allEdges().toSuperview()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
}

extension NotificationPicker: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return isTimeSet ? section2Models.count : 0
        case 2: return selectedIndexPath.section == section ? 2 : 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 2, indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TimeCell.identifier, for: indexPath) as! TimeCell
            
            cell.setup(controller: self)
            cell.configure(
                time: section3Model ?? Time(Date.now.hours, Date.now.minutes),
                onChange: { [unowned self, unowned tableView] time in
                    self.section3Model = time
                    
                    DispatchQueue.main.async {
                        let timeCell = tableView.cellForRow(at: IndexPath(row: 0, section: 2))
                        timeCell?.textLabel?.text = time.string
                    }
                }
            )
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            
            switch indexPath.section {
            case 0:
                cell.textLabel?.text = section1Model.readableString
            case 1:
                cell.textLabel?.text = Habit.Notification.before(section2Models[indexPath.row]).readableString
            case 2:
                cell.textLabel?.text = section3Model?.string ?? "select_time".localized
            default:
                cell.textLabel?.text = nil
            }
            
            cell.accessoryView = indexPath == selectedIndexPath ? UIImageView(image: UIImage(named: "checkmark")) : nil
            
            cell.textLabel?.font = AppTheme.current.fonts.regular(16)
            cell.textLabel?.textColor = AppTheme.current.colors.activeElementColor
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath != selectedIndexPath else { return }
        guard indexPath != IndexPath(row: 1, section: 2) else { return }
        
        let prevSelectedIndexPath = selectedIndexPath
        selectedIndexPath = indexPath
        tableView.reloadData()
        
        if indexPath.section == 2, indexPath.row == 0 {
            section3Model = Time(Date.now.hours, Date.now.minutes)
            onChangeHeight?(requiredHeight)
        } else if prevSelectedIndexPath.section == 2, prevSelectedIndexPath.row == 0 {
            section3Model = nil
            onChangeHeight?(requiredHeight)
        }
    }
    
}

extension NotificationPicker: EditorInput, DynamicHeightEditorInput {
    
    var requiredHeight: CGFloat {
        let timePickerHeight: CGFloat = section3Model == nil ? 0 : 96
        return CGFloat((isTimeSet ? section2Models.count : 0) + 2) * C.cellHeight + timePickerHeight
    }
    
}

private final class TimeCell: UITableViewCell, NotificationTimePickerOutput {
    
    static let identifier = "TimeCell"
    
    private var hasSetUp = false
    private let timePicker = ViewControllersFactory.notificationTimePicker
    
    private var onChangeTime: ((Time) -> Void)?
    
    func setup(controller: UIViewController) {
        guard !hasSetUp else { return }
        hasSetUp = true
        
        controller.addChild(timePicker)
        contentView.addSubview(timePicker.view)
        timePicker.view.height(timePicker.requiredHeight)
        timePicker.view.width(96)
        [timePicker.view.centerX(), timePicker.view.top(), timePicker.view.bottom()].toSuperview()
        timePicker.didMove(toParent: controller)
        
        timePicker.output = self
        
        selectionStyle = .none
    }
    
    func configure(time: Time, onChange: @escaping (Time) -> Void) {
        onChangeTime = onChange
        
        timePicker.setHours(time.hours)
        timePicker.setMinutes(time.minutes)
    }
    
    func didChangeHours(to hours: Int) {
        onChangeTime?(timePicker.time)
    }
    
    func didChangeMinutes(to minutes: Int) {
        onChangeTime?(timePicker.time)
    }
    
}

private struct C {
    static let cellHeight = CGFloat(44)
}
