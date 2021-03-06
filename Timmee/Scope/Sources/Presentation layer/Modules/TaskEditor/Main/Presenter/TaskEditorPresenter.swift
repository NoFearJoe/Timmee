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
    func setTaskKind(_ taskKind: Task.Kind)
    func setTaskTitle(_ title: String)
    func setDueDate(_ dueDate: Date)
    func setTags(_ tags: [Tag])
}

protocol TaskEditorOutput: class {
    func taskCreated()
}

final class TaskEditorPresenter {

    weak var view: TaskEditorViewInput!
    var interactor: TaskEditorInteractorInput!
    var router: TaskEditorRouterInput!
    
    private let tasksService = ServicesAssembly.shared.tasksService
    
    private lazy var filesService = FilesService(directory: "attachments")
    
    weak var output: TaskEditorOutput?
    
    weak var audioNotePresenter: TaskEditorAudioNotePresenterInput!
    
    private var regularitySettings: RegularitySettingsInput?
    
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
        
        view.setRepeatKind(self.task.kind)
                
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
        
        regularitySettings?.updateParameters(task: self.task)
    }
    
    func setTaskKind(_ taskKind: Task.Kind) {
        task.kind = taskKind
        view.setRepeatKind(taskKind)
        if isNewTask && taskKind == .regular {
            task.dueDate = Date()
            task.dueDate => TimeRounder.roundMinutes(task.dueDate?.minutes ?? 0).asMinutes
            task.repeating = RepeatMask(type: .every(.day))
        }
        regularitySettings?.updateParameters(task: task)
    }
    
    func setTaskTitle(_ title: String) {
        task.title = title
        view.setTaskTitle(self.task.title)
    }
    
    func setDueDate(_ dueDate: Date) {
        task.dueDate = dueDate
        regularitySettings?.updateParameters(task: task)
    }
    
    func setTags(_ tags: [Tag]) {
        task.tags = tags
        view.setTags(tags)
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
                self.attachmentsToRemove.forEach { self.filesService.removeFileFromDocuments(withName: $0) }
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
        
        if let time = timeTemplate?.time {
            task.dueDate = task.dueDate ?? Date()
            task.dueDate => time.hours.asHours
            task.dueDate => time.minutes.asMinutes
        } else {
            task.dueDate = nil
        }
        
        task.notificationTime = timeTemplate?.notificationTime
        task.notification = timeTemplate?.notification ?? .doNotNotify
        
        regularitySettings?.updateParameters(task: task)
    }
    
    func dueDateTimeChanged(to dueDate: Date?) {
        task.dueDate = dueDate
        if let time = task.timeTemplate?.time {
            task.dueDate => time.hours.asHours
            task.dueDate => time.minutes.asMinutes
        }
        if let dueDate = dueDate, let endDate = task.repeatEndingDate, dueDate >= endDate {
            let newEndDate = dueDate + 1.asDays
            task.repeatEndingDate = newEndDate
        }
        regularitySettings?.updateParameters(task: task)
    }
    
    func notificationChanged(to notification: TaskReminderSelectedNotification) {
        switch notification {
        case let .mask(notificationMask):
            task.notification = notificationMask
            task.notificationDate = nil
            task.notificationTime = nil
        case let .date(notificationDate):
            task.notification = .doNotNotify
            task.notificationDate = notificationDate
            task.notificationTime = nil
        case let .time(hours, minutes):
            task.notification = .doNotNotify
            task.notificationDate = nil
            task.notificationTime = (hours, minutes)
        }
        regularitySettings?.updateParameters(task: task)
    }
    
    func repeatChanged(to repeat: RepeatMask) {
        task.repeating = `repeat`
        regularitySettings?.updateParameters(task: task)
    }
    
    func repeatEndingDateChanged(to repeatEndingDate: Date?) {
        task.repeatEndingDate = repeatEndingDate
        regularitySettings?.updateParameters(task: task)
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
        task.dueDate = nil
        
        resetNotificationIfNeeded()
        
        regularitySettings?.updateParameters(task: task)
    }
    
    func dueDateTimeCleared() {
        task.dueDate = nil
        
        resetNotificationIfNeeded()
        regularitySettings?.updateParameters(task: task)
    }
    
    func notificationCleared() {
        task.notification = .doNotNotify
        task.notificationDate = nil
        task.notificationTime = nil
        regularitySettings?.updateParameters(task: task)
    }
    
    func repeatCleared() {
        task.repeating = .init(string: "")
        regularitySettings?.updateParameters(task: task)
    }
    
    func repeatEndingDateCleared() {
        task.repeatEndingDate = nil
        regularitySettings?.updateParameters(task: task)
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
        let photosData = task.attachments.compactMap { filesService.getFileFromDocuments(withName: $0) }
        let photos = photosData.compactMap { UIImage(data: $0) }
        
        guard !photos.isEmpty else { return }
        
        let selectedAttachmentIndex = task.attachments.index(of: attachment) ?? 0
        
        router.showPhotos(photos, startPosition: selectedAttachmentIndex)
    }
    
    func attachmentRemoved(_ attachment: String) {
        filesService.removeFileFromDocuments(withName: attachment)
        task.attachments.remove(object: attachment)
        
        view.setAttachments(task.attachments)
    }
    
    func willPresentTimeTemplatePicker(_ input: TaskTimeTemplatePickerInput) {
        input.setSelectedTimeTemplate(task.timeTemplate)
    }
    
    func willPresentDueDatePicker(_ picker: CalendarViewController) {
        picker.onSelectDate = { [unowned self] date in
            self.dueDateTimeChanged(to: date)
        }
        picker.configure(selectedDate: task.dueDate ?? Date(), minimumDate: Date().previousDay)
    }
    
    func willPresentDueDateTimePicker(_ picker: CalendarWithTimeViewController) {
        picker.onSelectDate = { [unowned self] date in
            self.dueDateTimeChanged(to: date)
        }
        picker.configure(selectedDate: task.dueDate ?? Date(), minimumDate: Date().previousDay)
        picker.setClearButtonVisible(task.kind == .single)
    }
    
    func willPresentReminderEditor(_ input: TaskReminderEditorInput) {
        if let notificationTime = task.notificationTime {
            input.setNotification(.time(notificationTime.0, notificationTime.1))
        } else if let notificationDate = task.notificationDate {
            input.setNotification(.date(notificationDate))
        } else {
            input.setNotification(.mask(task.notification))
        }
        
        switch task.kind {
        case .single:
            let shouldHideNotificationMasks = task.dueDate == nil && task.timeTemplate == nil
            input.setNotificationMasksVisible(!shouldHideNotificationMasks)
            input.setNotificationDatePickerVisible(true)
            input.setNotificationTimePickerVisible(false)
        case .regular:
            input.setNotificationMasksVisible(false)
            input.setNotificationDatePickerVisible(false)
            input.setNotificationTimePickerVisible(true)
        }
    }
    
    func willPresentRepeatingEditor(_ input: TaskRepeatingEditorInput) {
        input.canClear = task.kind == .single
        input.setRepeatMask(task.repeating)
        
        let shouldHideRepeatMasks: Bool
        switch task.kind {
        case .single: shouldHideRepeatMasks = true
        case .regular: shouldHideRepeatMasks = task.dueDate == nil && task.notificationDate == nil && task.notificationTime == nil
        }
        input.setRepeatMasksVisible(!shouldHideRepeatMasks)
    }
    
    func willPresentRepeatEndingDateEditor(_ calendar: CalendarViewController) {
        calendar.onSelectDate = { [unowned self] date in
            self.repeatEndingDateChanged(to: date)
        }
        let defaultDate = Date()
        let minimumDate = ((task.dueDate ?? defaultDate) + 1.asDays).startOfDay
        calendar.configure(selectedDate: task.repeatEndingDate ?? minimumDate, minimumDate: minimumDate)
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
    
    func didPrepareRegularitySettingsModule(_ moduleInput: RegularitySettingsInput) {
        regularitySettings = moduleInput
        regularitySettings?.output = self
    }

}

extension TaskEditorPresenter: RegularitySettingsOutput {
    
    func regularitySettings(_ module: RegularitySettingsInput, didClearParameter parameter: RegularitySettingsViewController.Parameter) {
        switch parameter {
        case .timeTemplate:
            task.timeTemplate = nil
            task.dueDate = nil
            resetNotificationIfNeeded()
        case .dueDateTime, .dueDate, .dueTime, .startDate:
            task.dueDate = nil
            resetNotificationIfNeeded()
        case .endDate:
            task.repeatEndingDate = nil
        case .notification:
            task.notification = .doNotNotify
            task.notificationDate = nil
            task.notificationTime = nil
        case .repeating:
            task.repeating = .init(string: "")
        }
        regularitySettings?.updateParameters(task: task)
    }
    
}

extension TaskEditorPresenter: SubtasksEditorTaskProvider, TaskEditorInteractorOutput, TaskEditorAudioNotePresenterOutput {}

private extension TaskEditorPresenter {
    
    func showLocation() {
        if let address = self.task.address {
            view.setLocation(address)
        } else {
            view.setLocation(nil)
        }
    }
    
    func resetNotificationIfNeeded() {
        // Если дата выполнения и временной шаблон не установлены, надо убрать уведомление
        if task.dueDate == nil, task.timeTemplate == nil {
            task.notification = .doNotNotify
            task.notificationDate = nil
            task.notificationTime = nil
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

                let stringAddress = address.compactMap { $0 }.joined(separator: ", ")
                
                completion(stringAddress)
            } else {
                completion(nil)
            }
        })
    }

}
