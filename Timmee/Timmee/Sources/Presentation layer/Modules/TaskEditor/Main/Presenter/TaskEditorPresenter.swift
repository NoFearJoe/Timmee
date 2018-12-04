//
//  TaskEditorPresenter.swift
//  Timmee
//
//  Created by Ilya Kharabet on 17.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIImage
import struct Foundation.URL
import struct Foundation.Date
import struct Foundation.Data
import class Foundation.DispatchQueue
import class Foundation.DispatchGroup
import class CoreLocation.CLGeocoder
import class CoreLocation.CLLocation
import class Foto.Photo

protocol TaskEditorInput: class {
    var output: TaskEditorOutput? { get set }
    
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
    
    weak var audioNotePresenter: TaskEditorAudioNotePresenterInput!
    
    var task: Task!
    private var listID: String?
    
    private var isNewTask = true
    
    private var attachmentsToRemove: [String] = []

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
        
        showFormattedDueDateTime(self.task.dueDate)
        
        showNotification()
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
        
        view.setAttachments(self.task.attachments)
        
        audioNotePresenter.updateAudioNoteField()
    }
    
    func setTaskTitle(_ title: String) {
        task.title = title
        view.setTaskTitle(self.task.title)
    }
    
    func setDueDate(_ dueDate: Date) {
        task.dueDate = dueDate
        showFormattedDueDateTime(dueDate)
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
                self.attachmentsToRemove.forEach { FilesService().removeFileFromDocuments(withName: $0) }
                NotificationsConfigurator.registerForLocalNotifications(application: UIApplication.shared) { isAuthorized in
                    if isAuthorized { self.interactor.scheduleTask(self.task) }
                    if self.isNewTask { self.output?.taskCreated() }
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
        
        task.dueDate = task.dueDate ?? Date()
        if let time = timeTemplate?.time {
            task.dueDate => time.hours.asHours
            task.dueDate => time.minutes.asMinutes
        }
        
        showFormattedDueDateTime(task.dueDate)

        if timeTemplate == nil {
            showNotification()
            if task.dueDate != nil {
                view.setRepeat(task.repeating)
            }
        } else {
            view.setNotification(.mask(.doNotNotify))
            view.setRepeat(task.repeating)
        }
        
        view.setTimeTemplate(timeTemplate)
    }
    
    func dueDateTimeChanged(to dueDate: Date?) {
        task.dueDate = dueDate
        if let time = task.timeTemplate?.time {
            task.dueDate => time.hours.asHours
            task.dueDate => time.minutes.asMinutes
        }
        showFormattedDueDateTime(task.dueDate)
    }
    
    func notificationChanged(to notification: TaskReminderSelectedNotification) {
        switch notification {
        case let .mask(notificationMask):
            task.notification = notificationMask
            task.notificationDate = nil
        case let .date(notificationDate):
            task.notificationDate = notificationDate
            task.notification = .doNotNotify
        }
        view.setNotification(notification)
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
        
        showFormattedDueDateTime(task.dueDate)
        updateNotification()
        updateRepeating()
        if task.dueDate != nil {
            view.setRepeat(task.repeating)
        }
        
        view.setTimeTemplate(nil)
    }
    
    func dueDateTimeCleared() {
        task.dueDate = nil
        
        view.setDueDateTime(nil, isOverdue: false)
        updateNotification()
        updateRepeating()
    }
    
    func notificationCleared() {
        task.notification = .doNotNotify
        task.notificationDate = nil
        view.setNotification(.mask(.doNotNotify))
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
        view.setTags([])
    }
    
    func attachmentsChanged(to attachments: [Photo]) {
        interactor.handleAttachmentsChange(oldAttachments: task.attachments, newAttachments: attachments) { newAttachmentPaths in
            self.task.attachments = newAttachmentPaths
            self.view.setAttachments(newAttachmentPaths)
            newAttachmentPaths.forEach { attachment in
                self.attachmentsToRemove.remove(object: attachment)
            }
        }
    }
    
    func attachmentsCleared() {
        attachmentsToRemove = task.attachments
        task.attachments = []
        
        view.setAttachments([])
    }
    
    func attachmentSelected(_ attachment: String) {
        let photosData = task.attachments.compactMap { FilesService().getFileFromDocuments(withName: $0) }
        let photos = photosData.compactMap { UIImage(data: $0) }
        
        guard !photos.isEmpty else { return }
        
        let selectedAttachmentIndex = task.attachments.index(of: attachment) ?? 0
        
        router.showPhotos(photos, startPosition: selectedAttachmentIndex)
    }
    
    func attachmentRemoved(_ attachment: String) {
        FilesService().removeFileFromDocuments(withName: attachment)
        task.attachments.remove(object: attachment)
        
        view.setAttachments(task.attachments)
    }
    
    func willPresentTimeTemplatePicker(_ input: TaskTimeTemplatePickerInput) {
        input.setSelectedTimeTemplate(task.timeTemplate)
    }
    
    func willPresentDueDatePicker(_ input: TaskDueDatePickerInput) {
        input.setDueDate(task.dueDate ?? Date())
    }
    
    func willPresentDueDateTimeEditor(_ input: TaskDueDateTimeEditorInput) {
        input.setDueDate(task.dueDate)
    }
    
    func willPresentReminderEditor(_ input: TaskReminderEditorInput) {
        if let notificationDate = task.notificationDate {
            input.setNotification(.date(notificationDate))
        } else {
            input.setNotification(.mask(task.notification))
        }
        
        let shouldHideNotificationMasks = task.dueDate == nil && task.timeTemplate == nil
        input.setNotificationMasksVisible(!shouldHideNotificationMasks)
    }
    
    func willPresentRepeatingEditor(_ input: TaskRepeatingEditorInput) {
        input.setRepeatMask(task.repeating)
        
        let shouldHideRepeatMasks = task.dueDate == nil && task.timeTemplate == nil && task.notificationDate == nil
        input.setRepeatMasksVisible(!shouldHideRepeatMasks)
    }
    
    func willPresentRepeatEndingDateEditor(_ input: TaskDueDateTimeEditorInput) {
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
    
    
    func willPresentAttachmentsPicker(_ input: TaskPhotoAttachmentsPickerInput) {
        input.setSelectedPhotos(task.attachments)
    }

}

extension TaskEditorPresenter: SubtasksEditorTaskProvider, TaskEditorInteractorOutput, TaskEditorAudioNotePresenterOutput {}

private extension TaskEditorPresenter {

    func showFormattedDueDateTime(_ dueDate: Date?) {
        let isOverdue = UserProperty.highlightOverdueTasks.bool() && (dueDate != nil && !(dueDate! >= Date()))
        view.setDueDateTime(dueDate?.asNearestDateString, isOverdue: isOverdue)
    }
    
    func showFormattedRepeatEndingDate(_ repeatEndingDate: Date?) {
        view.setRepeatEndingDate(repeatEndingDate?.asNearestDateString)
    }
    
    
    func showLocation() {
        if let address = self.task.address {
            view.setLocation(address)
        } else {
            view.setLocation(nil)
        }
    }
    
    func showNotification() {
        if let notificationDate = task.notificationDate {
            view.setNotification(.date(notificationDate))
        } else {
            view.setNotification(.mask(task.notification))
        }
    }
    
    func updateNotification() {
        // Если дата выполнения и временной шаблон не установлены, надо убрать уведомление
        if task.dueDate == nil, task.timeTemplate == nil {
            task.notification = .doNotNotify
            task.notificationDate = nil
        }
        showNotification()
    }
    
    func updateRepeating() {
        if task.dueDate == nil, task.timeTemplate == nil, task.notificationDate == nil {
            switch task.repeating.type {
            case .never, .every: task.repeating = .init(type: .never)
            case .on: return
            }
        }
        view.setRepeat(task.repeating)
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

                let stringAddress = address.compactMap { $0 }.joined(separator: ", ")
                
                completion(stringAddress)
            } else {
                completion(nil)
            }
        })
    }

}
