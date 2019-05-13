//
//  TaskTimeTemplatePicker.swift
//  Timmee
//
//  Created by i.kharabet on 15.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

protocol TaskTimeTemplatePickerInput: class {
    func setSelectedTimeTemplate(_ timeTemplate: TimeTemplate?)
}

protocol TaskTimeTemplatePickerOutput: class {
    func timeTemplateChanged(to timeTemplate: TimeTemplate?)
}

protocol TaskTimeTemplatePickerTransitionOutput: class {
    func didAskToShowTimeTemplateEditor(completion: @escaping  (TaskTimeTemplateEditor) -> Void)
    func didCompleteTimeTemplateEditing()
}

final class TaskTimeTemplatePicker: UIViewController {
    
    weak var output: TaskTimeTemplatePickerOutput?
    weak var transitionOutput: TaskTimeTemplatePickerTransitionOutput?
    weak var container: TaskParameterEditorOutput?
    
    @IBOutlet private var addTimeTemplateView: AddTimeTemplateView!
    @IBOutlet private var tableView: UITableView!
    
    private lazy var placeholder: PlaceholderView = PlaceholderView.loadedFromNib()
    
    private static let rowHeight: CGFloat = 52
    
    private var timeTemplatesService = ServicesAssembly.shared.timeTemplatesService
    
    private let cellActionsProvider = ListsSwipeTableActionsProvider()
    
    private var selectedTimeTemplate: TimeTemplate?
    private var timeTemplates: [TimeTemplate] = [] {
        didSet {
            timeTemplates.isEmpty ? showNoTimeTemplatesPlaceholder() : hideNoTimeTemplatesPlaceholder()
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPlaceholder()
        
        cellActionsProvider.onDelete = { [unowned self] indexPath in
            if let timeTemplate = self.timeTemplates.item(at: indexPath.row) {
                self.removeTimeTemplate(timeTemplate)
            }
        }
        cellActionsProvider.onEdit = { [unowned self] indexPath in
            if let timeTemplate = self.timeTemplates.item(at: indexPath.row) {
                self.transitionOutput?.didAskToShowTimeTemplateEditor { [unowned self] editor in
                    editor.output = self
                    editor.setTimeTemplate(timeTemplate)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTimeTemplates()
    }
    
    @IBAction func showTimeTemplateEditor() {
        transitionOutput?.didAskToShowTimeTemplateEditor { [unowned self] editor in
            editor.output = self
            editor.setTimeTemplate(nil)
        }
    }
    
}

// MARK: - TaskTimeTemplatePickerInput

extension TaskTimeTemplatePicker: TaskTimeTemplatePickerInput {
    
    func setSelectedTimeTemplate(_ timeTemplate: TimeTemplate?) {
        self.selectedTimeTemplate = timeTemplate
        tableView.reloadData()
    }
    
}

// MARK: - UITableViewDataSource

extension TaskTimeTemplatePicker: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeTemplates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimeTemplateTableCell",
                                                 for: indexPath) as! TimeTemplateTableCell
        
        if let timeTemplate = timeTemplates.item(at: indexPath.row) {
            cell.setTimeTemplate(timeTemplate)
            cell.isPicked = selectedTimeTemplate == timeTemplate
            cell.delegate = cellActionsProvider
        }
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension TaskTimeTemplatePicker: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectTimeTemplate(at: indexPath.row)
        UIView.performWithoutAnimation {
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TaskTimeTemplatePicker.rowHeight
    }
    
}

fileprivate extension TaskTimeTemplatePicker {
    
    func updateTimeTemplates() {
        var timeTemplates = timeTemplatesService.fetchTimeTemplates()
        
        if !UserProperty.isDefaultTimeTemplatesAdded.bool() {
            timeTemplates.append(contentsOf: defaultTimeTemplates)
            UserProperty.isDefaultTimeTemplatesAdded.setBool(true)
            
            defaultTimeTemplates.forEach { template in
                self.timeTemplatesService.createOrUpdateTimeTemplate(template, completion: nil)
            }
        }
        
        self.timeTemplates = timeTemplates
    }
    
}

// MARK: - Time templates management

fileprivate extension TaskTimeTemplatePicker {
    
    func addNewTimeTemplate(_ timeTemplate: TimeTemplate) {
        timeTemplates.append(timeTemplate)
        
        timeTemplatesService.createOrUpdateTimeTemplate(timeTemplate, completion: nil)
        
        if let index = timeTemplates.index(of: timeTemplate) {
            tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .none)
        } else {
            tableView.reloadData()
        }
    }
    
    func removeTimeTemplate(_ timeTemplate: TimeTemplate) {
        if timeTemplate == selectedTimeTemplate {
            selectedTimeTemplate = nil
            output?.timeTemplateChanged(to: nil)
        }
        timeTemplates.remove(object: timeTemplate)
        
        timeTemplatesService.removeTimeTemplate(timeTemplate, completion: nil)
        
        if let index = timeTemplates.index(of: timeTemplate) {
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .none)
        } else {
            tableView.reloadData()
        }
    }
    
    func updateTimeTemplate(_ timeTemplate: TimeTemplate) {
        timeTemplates.sort(by: { $0.title < $1.title })
        
        timeTemplatesService.createOrUpdateTimeTemplate(timeTemplate, completion: nil)
        
        if let index = timeTemplates.index(of: timeTemplate) {
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        } else {
            tableView.reloadData()
        }
    }
    
    func selectTimeTemplate(at index: Int) {
        if let timeTemplate = timeTemplates.item(at: index) {
            selectedTimeTemplate = timeTemplate
            output?.timeTemplateChanged(to: timeTemplate)
        }
    }
    
}

// MARK: - TaskTimeTemplateEditorOutput

extension TaskTimeTemplatePicker: TaskTimeTemplateEditorOutput {
    
    func timeTemplateCreated() {
        transitionOutput?.didCompleteTimeTemplateEditing()
    }
    
}

// MARK: - Default time templates

fileprivate extension TaskTimeTemplatePicker {
    
    var defaultTimeTemplates: [TimeTemplate] {
        return [
            TimeTemplate(id: "_ttMorning", title: "template_at_morning".localized, time: (9, 0), notification: .justInTime, notificationTime: nil),
            TimeTemplate(id: "_ttLaunch", title: "template_at_launch".localized, time: (14, 0), notification: .justInTime, notificationTime: nil),
            TimeTemplate(id: "_ttAfternoon", title: "template_at_afternoon".localized, time: (20, 0), notification: .justInTime, notificationTime: nil)
        ]
    }
    
}

// MARK: - Placeholder

fileprivate extension TaskTimeTemplatePicker {
    
    func showNoTimeTemplatesPlaceholder() {
        guard placeholder.isHidden else { return }
        self.placeholder.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {
            self.placeholder.alpha = 1
        }, completion: { _ in
            self.placeholder.isHidden = false
        })
    }
    
    func hideNoTimeTemplatesPlaceholder() {
        guard !placeholder.isHidden else { return }
        self.placeholder.alpha = 1
        UIView.animate(withDuration: 0.2, animations: {
            self.placeholder.alpha = 0
        }, completion: { _ in
            self.placeholder.isHidden = true
        })
    }
    
    func setupPlaceholder() {
        placeholder.setup(into: view)
        placeholder.icon = #imageLiteral(resourceName: "faceIDBig")
        placeholder.title = "no_time_templates".localized
        placeholder.subtitle = "no_time_templates_hint".localized
        placeholder.isHidden = true
    }
    
}

extension TaskTimeTemplatePicker: TaskParameterEditorInput {
    var requiredHeight: CGFloat {
        return CGFloat(6) * TaskTimeTemplatePicker.rowHeight + 44 + 96
    }
}

final class TimeTemplateTableCell: SwipeTableViewCell {
    
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var subtitleLabel: UILabel!
    @IBOutlet fileprivate var selectedIndicator: UIView!
    
    var isPicked: Bool = false {
        didSet {
            selectedIndicator.isHidden = !isPicked
        }
    }
    
    func setTimeTemplate(_ timeTemplate: TimeTemplate) {
        setupAppearance()
        
        titleLabel.text = timeTemplate.title
        subtitleLabel.text = timeTemplate.makeDueTimeAndNotificationString()
    }
    
    func setupAppearance() {
        titleLabel.textColor = AppTheme.current.tintColor
        subtitleLabel.textColor = AppTheme.current.secondaryTintColor
        selectedIndicator.backgroundColor = AppTheme.current.blueColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setupAppearance()
    }
    
}
