//
//  TaskEditorPresenter.swift
//  Timmee
//
//  Created by Ilya Kharabet on 17.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date
import class Foundation.DispatchQueue
import class CoreLocation.CLGeocoder
import class CoreLocation.CLLocation

protocol TaskEditorInput: class {
    weak var output: TaskEditorOutput? { get set }
    
    func setListID(_ listID: String?)
    func setTask(_ task: Task?)
    func setTaskTitle(_ title: String)
    func setDueDate(_ dueDate: Date)
}

protocol TaskEditorOutput: class {
    func taskCreated()
}

final class TaskEditorPresenter {

    weak var view: TaskEditorViewInput!
    var interactor: TaskEditorInteractorInput!
    var router: TaskEditorRouterInput!
    
    weak var output: TaskEditorOutput?
    
    var task: Task!
    fileprivate var listID: String?
    
    fileprivate var isNewTask = true

}

extension TaskEditorPresenter: TaskEditorInput {

    func setListID(_ listID: String?) {
        self.listID = listID
    }
    
    func setTask(_ task: Task?) {
        self.task = task?.copy ?? interactor.createTask()
        
        isNewTask = task == nil
        
        view.setCloseButtonVisible(task == nil)
        
        view.setTaskTitle(self.task.title)
        view.setTaskNote(self.task.note)
        
        view.setTimeTemplate(self.task.timeTemplate)
        
        showFormattedDueDate(self.task.dueDate)
        
        view.setReminder(self.task.notification)
        view.setRepeat(self.task.repeating)
        
        showFormattedRepeatEndingDate(self.task.repeatEndingDate)
        
        if self.task.location != nil && self.task.address == nil {
            decodeLocation(self.task.location) { address in
                self.task.address = address
                self.showLocation()
            }
        } else {
            showLocation()
        }
        
        view.setLocationReminderIsSelected(self.task.shouldNotifyAtLocation)
        
        view.setTaskImportant(self.task.isImportant)
        
        view.setTags(self.task.tags)
    }
    
    func setTaskTitle(_ title: String) {
        task.title = title
        view.setTaskTitle(self.task.title)
    }
    
    func setDueDate(_ dueDate: Date) {
        task.dueDate = dueDate
        showFormattedDueDate(dueDate)
    }

}

extension TaskEditorPresenter: TaskEditorViewOutput {
    
    func viewDidAppear() {
        
    }
    
    func closeButtonPressed() {
        router.close()
    }
    
    func doneButtonPressed() {
        task.title = view.getTaskTitle()
        task.note = view.getTaskNote()
        
        interactor.saveTask(task, listID: isNewTask ? listID : nil, success: { [weak self] in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.interactor.scheduleTask(self.task)
                if self.isNewTask {
                    self.output?.taskCreated()
                }
            }
        }, fail: nil)
        
        router.close()
    }
    
    
    func taskTitleChanged(to taskTitle: String) {
        task.title = taskTitle
    }
    
    func taskNoteChanged(to taskNote: String) {
        task.note = taskNote
    }
    
    func timeTemplateChanged(to timeTemplate: TimeTemplate?) {
        task.timeTemplate = timeTemplate

        if timeTemplate == nil {
            showFormattedDueDate(task.dueDate)
            view.setReminder(task.notification)
            if task.dueDate != nil {
                view.setRepeat(task.repeating)
            }
        } else {
            view.setDueDate(nil)
            view.setReminder(.doNotNotify)
            view.setRepeat(task.repeating)
        }
        
        view.setTimeTemplate(timeTemplate)
    }
    
    func dueDateChanged(to dueDate: Date?) {
        task.dueDate = dueDate
        showFormattedDueDate(dueDate)
    }
    
    func reminderChanged(to reminder: NotificationMask) {
        task.notification = reminder
        view.setReminder(reminder)
    }
    
    func repeatChanged(to repeat: RepeatMask) {
        task.repeating = `repeat`
        view.setRepeat(`repeat`)
    }
    
    func repeatEndingDateChanged(to repeatEndingDate: Date?) {
        task.repeatEndingDate = repeatEndingDate
        showFormattedRepeatEndingDate(repeatEndingDate)
    }
    
    func locationChanged(to location: CLLocation?) {
        task.location = location
        decodeLocation(location) { [weak self] address in
            self?.task.address = address
            self?.showLocation()
        }
        showLocation()
    }
    
    func locationReminderSelectionChanged(to isSelected: Bool) {
        task.shouldNotifyAtLocation = isSelected
    }
    
    func taskImportantChanged(to isImportant: Bool) {
        task.isImportant = isImportant
    }
    
    
    func tagSelected(_ tag: Tag) {
        task.tags.append(tag)
        view.setTags(task.tags)
    }
    
    func tagDeselected(_ tag: Tag) {
        task.tags.remove(object: tag)
        view.setTags(task.tags)
    }
    
    func tagRemoved(_ tag: Tag) {
        task.tags.remove(object: tag)
        view.setTags(task.tags)
    }
    
    func tagUpdated(_ tag: Tag) {
        if let index = task.tags.index(of: tag) {
            task.tags[index] = tag
            view.setTags(task.tags)
        }
    }
    
    func timeTemplateCleared() {
        task.timeTemplate = nil
        
        showFormattedDueDate(task.dueDate)
        view.setReminder(task.notification)
        if task.dueDate != nil {
            view.setRepeat(task.repeating)
        }
        
        view.setTimeTemplate(nil)
    }
    
    func dueDateCleared() {
        task.dueDate = nil
        
        view.setDueDate(nil)
    }
    
    func reminderCleared() {
        task.notification = .doNotNotify
        view.setReminder(.doNotNotify)
    }
    
    func repeatCleared() {
        task.repeating = .init(string: "")
        view.setRepeat(.init(string: ""))
    }
    
    func repeatEndingDateCleared() {
        task.repeatEndingDate = nil
        showFormattedRepeatEndingDate(nil)
    }
    
    func locationCleared() {
        task.location = nil
        task.address = nil
        view.setLocation(nil)
    }
    
    func tagsCleared() {
        task.tags = []
    }
    
    func willPresentTimeTemplatePicker(_ input: TaskTimeTemplatePickerInput) {
        input.setSelectedTimeTemplate(task.timeTemplate)
    }
    
    func willPresentDueDateEditor(_ input: TaskDueDateEditorInput) {
        input.setDueDate(task.dueDate)
    }
    
    func willPresentReminderEditor(_ input: TaskReminderEditorInput) {
        input.setNotificationMask(task.notification)
    }
    
    func willPresentRepeatingEditor(_ input: TaskRepeatingEditorInput) {
        input.setRepeatMask(task.repeating)
    }
    
    func willPresentRepeatEndingDateEditor(_ input: TaskDueDateEditorInput) {
        let minimumDate = task.dueDate + 1.asDays
        input.setMinimumDate(minimumDate)
        input.setDueDate(task.repeatEndingDate ?? minimumDate)
    }
    
    func willPresentLocationEditor(_ input: TaskLocationEditorInput) {
        if let location = task.location {
            input.setLocation(location)
        }
    }
    
    func willPresentTagsPicker(_ input: TaskTagsPickerInput) {
        input.setSelectedTags(task.tags)
    }
    
    
    func willPresentIntervalRepeatingPicker(_ input: TaskIntervalRepeatingPickerInput) {
        input.setRepeatingMask(task.repeating)
    }
    
    func willPresentWeeklyRepeatingPicker(_ input: TaskWeeklyRepeatingPickerInput) {
        input.setRepeatingMask(task.repeating)
    }

}

extension TaskEditorPresenter: SubtasksEditorTaskProvider {}

extension TaskEditorPresenter: TaskEditorInteractorOutput {}

fileprivate extension TaskEditorPresenter {

    func showFormattedDueDate(_ dueDate: Date?) {
        view.setDueDate(makeFormattedString(from: dueDate))
    }
    
    func showFormattedRepeatEndingDate(_ repeatEndingDate: Date?) {
        if let dateString = makeFormattedString(from: repeatEndingDate) {
            view.setRepeatEndingDate("until".localized + " " + dateString)
        } else {
            view.setRepeatEndingDate(nil)
        }
    }
    
    // TODO: Refactoring cause of reuse in TaskTimeTemplateEditor
    func makeFormattedString(from date: Date?) -> String? {
        if let date = date {
            let nearestDate = NearestDate(date: date)
            
            if case .custom = nearestDate {
                return date.asDayMonthTime
            } else {
                return nearestDate.title + ", " + date.asTimeString
            }
        } else {
            return nil
        }
    }
    
    
    func showLocation() {
        if let address = self.task.address {
            view.setLocation(address)
        } else {
            view.setLocation(nil)
        }
    }
    
    func decodeLocation(_ location: CLLocation?, completion: @escaping (String?) -> Void) {
        guard let location = location else {
            completion(nil)
            return
        }
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            if let placemark = placemarks?.first {
                var address: [String?] = []

                let name = placemark.name
                let street = placemark.thoroughfare
                let number = placemark.subThoroughfare

                if let name = name, let street = street, name.contains(street) {
                    address.insert(name, at: 0)
                } else {
                    address.append(name)
                    if let street = street, let number = number {
                        address.append(street + " " + number)
                    }
                }

                let stringAddress = address.flatMap { $0 }.joined(separator: ", ")
                
                completion(stringAddress)
            } else {
                completion(nil)
            }
        })
    }

}
