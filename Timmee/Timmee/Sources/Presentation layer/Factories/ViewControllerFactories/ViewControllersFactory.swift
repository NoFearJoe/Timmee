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

final class ViewControllersFactory {

    static var mainTop: MainTopViewController {
        return StoryboardsFactory.mainTop.initialViewController()
    }
    
    static var tableListRepresentation: TableListRepresentationView {
        return StoryboardsFactory.listRepresentations.viewController(id: "Table")
    }
    
    static var listEditor: ListEditorView {
        return StoryboardsFactory.listEditor.initialViewController()
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
    
    static var taskDueDateEditor: TaskDueDateEditor {
        return StoryboardsFactory.taskParameterEditors.viewController(id: "TaskDueDateEditor")
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
    
    static var inApp: InAppPurchaseViewController {
        return StoryboardsFactory.settings.viewController(id: "InAppPurchaseViewController")
    }

    
    static var search: SearchViewController {
        return StoryboardsFactory.search.initialViewController()
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
