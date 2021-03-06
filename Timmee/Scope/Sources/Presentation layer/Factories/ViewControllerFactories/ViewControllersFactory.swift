//
//  ViewControllersFactory.swift
//  Timmee
//
//  Created by Ilya Kharabet on 14.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIStoryboard
import class UIKit.UIViewController
import class UIKit.UINavigationController
import class MessageUI.MFMailComposeViewController

final class ViewControllersFactory {

    static var main: MainViewController {
        return StoryboardsFactory.main.initialViewController()
    }
    
    static var lists: ListsViewController {
        return StoryboardsFactory.lists.viewController(id: "Lists")
    }
    
    static var tableListRepresentation: TableListRepresentationView {
        return StoryboardsFactory.listRepresentations.viewController(id: "Table")
    }
    
    static var listEditor: ListEditorView {
        return StoryboardsFactory.listEditor.initialViewController()
    }
    
    static var smartListsPicker: SmartListPickerView {
        return StoryboardsFactory.listEditor.viewController(id: "SmartListPicker")
    }
    
    static var tasksImportView: TasksImportView {
        return StoryboardsFactory.listEditor.viewController(id: "TasksImportView")
    }
    
    static var taskEditor: TaskEditorView {
        return StoryboardsFactory.taskEditor.initialViewController()
    }
    
    static var subtasksEditor: SubtasksEditor {
        return StoryboardsFactory.taskEditor.viewController(id: "SubtasksEditor")
    }
    
    static var taskParameterEditorContainer: TaskParameterEditorContainer {
        return StoryboardsFactory.taskParameterEditors.initialViewController()
    }
    
//    static var taskDueDateTimeEditor: TaskDueDateTimeEditor {
//        return StoryboardsFactory.taskParameterEditors.viewController(id: "TaskDueDateTimeEditor")
//    }
//
//    static var taskDueDatePicker: TaskDueDatePicker {
//        return StoryboardsFactory.taskParameterEditors.viewController(id: "TaskDueDatePicker")
//    }
    
    static var timePicker: TimePicker {
        return TimePicker(design: defaultTimePickerDesign)
//        return StoryboardsFactory.taskParameterEditors.viewController(id: "TaskDueTimePicker")
    }
    
    static var taskReminderEditor: TaskReminderEditor {
        return StoryboardsFactory.taskParameterEditors.viewController(id: "TaskReminderEditor")
    }
    
    static var taskRepeatingEditor: TaskRepeatingEditor {
        return StoryboardsFactory.taskParameterEditors.viewController(id: "TaskRepeatingEditor")
    }
    
    static var taskIntervalRepeatingPicker: TaskIntervalRepeatingPicker {
        return StoryboardsFactory.taskParameterEditors.viewController(id: "TaskIntervalRepeatingPicker")
    }
    
    static var taskWeeklyRepeatingPicker: TaskWeeklyRepeatingPicker {
        return StoryboardsFactory.taskParameterEditors.viewController(id: "TaskWeeklyRepeatingPicker")
    }
    
    static var taskLocationEditor: TaskLocationEditor {
        return StoryboardsFactory.taskParameterEditors.viewController(id: "TaskLocationEditor")
    }
    
    static var taskTagsPicker: TaskTagsPicker {
        return StoryboardsFactory.taskParameterEditors.viewController(id: "TaskTagsPicker")
    }
    
    static var taskTimeTemplatePicker: TaskTimeTemplatePicker {
        return StoryboardsFactory.taskParameterEditors.viewController(id: "TaskTimeTemplatePicker")
    }
    
    static var taskTimeTemplateEditor: TaskTimeTemplateEditor {
        return StoryboardsFactory.taskParameterEditors.viewController(id: "TaskTimeTemplateEditor")
    }
    
    static var taskPhotoAttachmentsPicker: TaskPhotoAttachmentsPicker {
        return StoryboardsFactory.taskParameterEditors.viewController(id: "TaskPhotoAttachmentsPicker")
    }
    
    
    static var pinCreation: PinCreationViewController {
        return StoryboardsFactory.pin.viewController(id: "PinCreation")
    }
    
    static var pinAuthentication: PinAuthenticationViewController {
        return StoryboardsFactory.pin.viewController(id: "PinAuthentication")
    }
    
    static var biometricsActivation: BiometricsActivationController {
        return StoryboardsFactory.pin.viewController(id: "BiometricsActivation")
    }
    
    
    static var settings: UINavigationController {
        return StoryboardsFactory.settings.initialViewController()
    }
    
    static var aboutApp: AboutAppViewController {
        return StoryboardsFactory.settings.viewController(id: "AboutAppViewController")
    }
    
    static var mail: MFMailComposeViewController {
        let viewController = MFMailComposeViewController()
        if #available(iOS 11.0, *) {
            viewController.setPreferredSendingEmailAddress("mesterra.co@gmail.com")
        }
        viewController.setToRecipients(["mesterra.co@gmail.com"])
        return viewController
    }

    
    static var search: SearchViewController {
        return StoryboardsFactory.search.initialViewController()
    }
    
    
    static var photoPreview: PhotoPreviewViewController {
        return StoryboardsFactory.photoPreview.initialViewController()
    }
    
    
    static var education: EducationViewController {
        return StoryboardsFactory.education.initialViewController()
    }
    
    static var initialEducationScreen: InitialEducationScreen {
        return StoryboardsFactory.education.viewController(id: "InitialEducationScreen")
    }
    
    static var featuresEducationScreen: FeaturesEducationScreen {
        return StoryboardsFactory.education.viewController(id: "FeaturesEducationScreen")
    }
    
    static var notificationsSetupSuggestionScreen: NotificationsSetupSuggestionScreen {
        return StoryboardsFactory.education.viewController(id: "NotificationsSetupSuggestionScreen")
    }
    
    static var pinCodeSetupSuggestionEducationScreen: PinCodeSetupSuggestionEducationScreen {
        return StoryboardsFactory.education.viewController(id: "PinCodeSetupSuggestionEducationScreen")
    }
    
    static var finalEducationScreen: FinalEducationScreen {
        return StoryboardsFactory.education.viewController(id: "FinalEducationScreen")
    }
    
}

fileprivate extension UIStoryboard {

    func initialViewController<T: UIViewController>() -> T {
        return instantiateInitialViewController() as! T
    }
    
    func viewController<T: UIViewController>(id: String) -> T {
        return instantiateViewController(withIdentifier: id) as! T
    }

}

/// @storyboard:ViewController @id:initial
class ViewController: UIViewController {
    
}
