//
//  TaskTimeTemplatePicker.swift
//  Timmee
//
//  Created by i.kharabet on 15.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

protocol TaskTimeTemplatePickerInput: class {
    func setSelectedTimeTemplate(_ timeTemplate: TimeTemplate?)
}

protocol TaskTimeTemplatePickerOutput: class {
    func timeTemplateChanged(to timeTemplate: TimeTemplate?)
}

final class TaskTimeTemplatePicker: UIViewController {
    
    weak var output: TaskTimeTemplatePickerOutput?
    
    @IBOutlet fileprivate var addTimeTemplateView: AddTimeTemplateView!
    @IBOutlet fileprivate var tableView: UITableView!
    
    fileprivate lazy var placeholder: PlaceholderView = PlaceholderView.loadedFromNib()
    
    fileprivate static let rowHeight: CGFloat = 52
    
    fileprivate var timeTemplatesService = TimeTemplatesService()
    
    fileprivate let cellActionsProvider = SubtaskCellActionsProvider()
    
    fileprivate var selectedTimeTemplate: TimeTemplate?
    fileprivate var timeTemplates: [TimeTemplate] = [] {
        didSet {
            timeTemplates.isEmpty ? showNoTimeTemplatesPlaceholder() : hideNoTimeTemplatesPlaceholder()
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
        
        timeTemplates = timeTemplatesService.fetchTimeTemplates()
        tableView.reloadData()
    }
    
    @IBAction func showTimeTemplateEditor() {
        
    }
    
}

// MARK: - TaskTimeTemplatePickerInput

extension TaskTimeTemplatePicker: TaskTimeTemplatePickerInput {
    
    func setSelectedTimeTemplate(_ timeTemplate: TimeTemplate?) {
        self.selectedTimeTemplate = timeTemplate
        tableView.reloadData()
    }
    
}

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
        }
        
        return cell
    }
    
}

extension TaskTimeTemplatePicker: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectTimeTemplate(at: indexPath.row)
        UIView.performWithoutAnimation {
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TaskTimeTemplatePicker.rowHeight
    }
    
}

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
        timeTemplates.sort(by: { $0.0.title < $0.1.title })
        
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
        return CGFloat(6) * TaskTimeTemplatePicker.rowHeight + 44
    }
}

final class TimeTemplateTableCell: UITableViewCell {
    
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var subtitleLabel: UILabel!
    @IBOutlet fileprivate var selectedIndicator: UIView!
    
    var isPicked: Bool = false {
        didSet {
            selectedIndicator.isHidden = !isPicked
        }
    }
    
    func setTimeTemplate(_ timeTemplate: TimeTemplate) {
        titleLabel.text = timeTemplate.title
        subtitleLabel.text = timeTemplate.dueDate.asDayMonthTime + ", " + timeTemplate.notification.title
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
