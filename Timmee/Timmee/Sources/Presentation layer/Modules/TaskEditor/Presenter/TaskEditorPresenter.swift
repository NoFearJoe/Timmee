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
    
    fileprivate var task: Task!
    fileprivate var listID: String?
    
    fileprivate var isNewTask = true
    
    fileprivate var sortedSubtasks: [Subtask] {
        return task.subtasks.sorted(by: { $0.0.sortPosition < $0.1.sortPosition })
    }

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
        
        view.reloadSubtasks()
        
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
        decodeLocation(location) { address in
            self.task.address = address
            self.showLocation()
        }
        showLocation()
    }
    
    func locationReminderSelectionChanged(to isSelected: Bool) {
        task.shouldNotifyAtLocation = isSelected
    }
    
    func taskImportantChanged(to isImportant: Bool) {
        task.isImportant = isImportant
    }
    
    
    func addSubtask(with title: String) {
        let subtask = interactor.createSubtask(sortPosition: nextSubtaskSortPosition())
        subtask.title = title
        task.subtasks.append(subtask)
        
        interactor.addSubtask(subtask, task: task) { [weak self] in
            if let index = self?.sortedSubtasks.index(where: { $0.id == subtask.id }) {
                self?.view.batchReloadSubtask(insertions: [index],
                                              deletions: [],
                                              updates: [])
            }
        }
    }
    
    func updateSubtask(at index: Int, newTitle: String) {
        if let subtask = sortedSubtasks.item(at: index) {
            subtask.title = newTitle
            interactor.saveSubtask(subtask, completion: { [weak self] in
                self?.view.batchReloadSubtask(insertions: [],
                                              deletions: [],
                                              updates: [index])
            })
        }
    }
    
    func removeSubtask(at index: Int) {
        if let subtask = sortedSubtasks.item(at: index) {
            interactor.removeSubtask(subtask, completion: { [weak self] in
                guard let `self` = self else { return }
                guard let deletionIndex = self.task.subtasks.index(where: { $0.id == subtask.id }) else { return }
                self.task.subtasks.remove(at: deletionIndex)
                self.view.batchReloadSubtask(insertions: [],
                                              deletions: [index],
                                              updates: [])
            })
        }
    }
    
    func exchangeSubtasks(at indexes: (Int, Int)) {
        guard indexes.0 != indexes.1 else { return }
        if let fromSubtask = sortedSubtasks.item(at: indexes.0),
           let toSubtask = sortedSubtasks.item(at: indexes.1) {
            
            let targetPosition = toSubtask.sortPosition
            
            let range = Int(min(indexes.0, indexes.1))...Int(max(indexes.0, indexes.1))
            let subtasks = sortedSubtasks
            range.forEach { index in
                guard index != indexes.0 else { return }
                if let subtask = subtasks.item(at: index) {
                    if indexes.0 > indexes.1 {
                        subtask.sortPosition += 1
                    } else {
                        subtask.sortPosition -= 1
                    }
                }
            }
            
            fromSubtask.sortPosition = targetPosition
            
            view.batchReloadSubtask(insertions: [],
                                    deletions: [],
                                    updates: range.map { $0 })
        }
    }
    
    func doneSubtask(at index: Int) {
        if let subtask = sortedSubtasks.item(at: index) {
            subtask.isDone = !subtask.isDone
            interactor.saveSubtask(subtask, completion: { [weak self] in
                self?.view.batchReloadSubtask(insertions: [],
                                              deletions: [],
                                              updates: [index])
            })
        }
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
    
    
    func dueDateCleared() {
        task.dueDate = nil
        task.notification = .doNotNotify
        task.repeating = .init(string: "")
        
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

extension TaskEditorPresenter: TaskEditorInteractorOutput {}

extension TaskEditorPresenter: TaskEditorSubtasksDataSource {

    func subtasksCount() -> Int {
        return sortedSubtasks.count
    }
    
    func subtask(at index: Int) -> Subtask? {
        return sortedSubtasks.item(at: index)
    }

}

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

fileprivate extension TaskEditorPresenter {

    func nextSubtaskSortPosition() -> Int {
        return (sortedSubtasks.last?.sortPosition ?? 0) + 1
    }

}
