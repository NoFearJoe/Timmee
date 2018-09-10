//
//  SprintCreationViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 13.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

/*
 Есть 2 кейса при редактировании спринта:
 1. Спринт уже есть. Тогда он передается в свойство sprint
 2. Спринта нет или он создан не до конца. Тогда его нужно создать:
     1. Находим недосозданный спринт (isCompleted == false):
         + Присваиваем в свойство sprint
         - 1. Находим последний спринт
           2. Создаем новый с повышенным порядковым числом
           3. Сохраняем в БД
 */

final class SprintCreationViewController: UIViewController, SprintInteractorTrait, AlertInput {
    
    @IBOutlet private var headerView: LargeHeaderView!
    @IBOutlet private var sectionSwitcher: Switcher!
    @IBOutlet private var addButton: UIButton!
    
    private var contentViewController: SprintContentViewController!
    
    private var currentSection = SprintSection.habits
    
    var sprint: List! {
        didSet {
            contentViewController.sprintID = sprint.id
            headerView.titleLabel.text = "Sprint".localized + " #\(sprint.sortPosition)"
            showStartDate(sprint.creationDate)
        }
    }
    
    let sprintsService = ServicesAssembly.shared.listsService
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDoneButton()
        headerView.leftButton?.isHidden = sprint == nil
        sectionSwitcher.items = [SprintSection.habits.title, SprintSection.targets.title]
        sectionSwitcher.selectedItemIndex = 0
        sectionSwitcher.addTarget(self, action: #selector(onSwitchSection), for: .touchUpInside)
        if sprint == nil {
            getOrCreateSprint { [weak self] sprint in
                self?.sprint = sprint
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard sprint != nil else { return }
        if sprint.creationDate.compare(Date().startOfDay) == .orderedAscending {
            sprint.creationDate = Date().nextDay.startOfDay
            showStartDate(sprint.creationDate)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SprintContent" {
            contentViewController = segue.destination as! SprintContentViewController
            contentViewController.section = currentSection
            contentViewController.transitionHandler = self
        } else if segue.identifier == "ShowTargetCreation" {
            guard let controller = segue.destination as? TargetCreationViewController else { return }
            controller.setTarget(sender as? Task, listID: sprint.id)
        } else if segue.identifier == "ShowHabitCreation" {
            guard let controller = segue.destination as? HabitCreationViewController else { return }
            controller.setHabit(sender as? Task, listID: sprint.id)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func showStartDate(_ date: Date) {
        let resultStirng = NSMutableAttributedString(string: "starts".localized + " ", attributes: [.foregroundColor: AppTheme.current.colors.activeElementColor])
        let dateString = NSAttributedString(string: date.asNearestShortDateString.lowercased(), attributes: [.foregroundColor: AppTheme.current.colors.mainElementColor])
        resultStirng.append(dateString)
        headerView.subtitleLabel.attributedText = resultStirng
    }
    
    @objc private func onSwitchSection() {
        currentSection = SprintSection(rawValue: sectionSwitcher.selectedItemIndex) ?? .habits
        contentViewController.section = currentSection
    }
    
    @IBAction private func onTapToSprintStartDate() {
        let editorContainer = ViewControllersFactory.editorContainer
        editorContainer.loadViewIfNeeded()
        let dueDatePicker = ViewControllersFactory.dueDatePicker
        dueDatePicker.output = self
        dueDatePicker.loadViewIfNeeded()
        dueDatePicker.setDueDate(sprint.creationDate)
        editorContainer.setViewController(dueDatePicker)
        editorContainer.output = self
        present(editorContainer, animated: true, completion: nil)
    }
    
    @IBAction private func onClose() {
        // TODO: Alert, then close
        close()
    }
    
    @IBAction private func onAdd() {
        switch currentSection {
        case .targets: performSegue(withIdentifier: "ShowTargetCreation", sender: nil)
        case .habits: performSegue(withIdentifier: "ShowHabitCreation", sender: nil)
        }
    }
    
    @IBAction private func onDone() {
        showAlert(title: "attention".localized,
                  message: "are_you_sure_you_want_to_finish_sprint_creation".localized,
                  actions: [.cancel, .ok("finish".localized)])
            { action in
                guard case .ok = action else { return }
                self.sprint.note = ""
                self.saveSprint(self.sprint) { [weak self] success in
                    self?.close()
                }
            }
    }
    
    func setupDoneButton() {
        headerView.rightButton?.setTitleColor(AppTheme.current.colors.inactiveElementColor, for: .disabled)
        headerView.rightButton?.setTitleColor(AppTheme.current.colors.mainElementColor, for: .normal)
    }
    
    func close() {
        if presentingViewController == nil {
            (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = ViewControllersFactory.toady
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
}

extension SprintCreationViewController: DueDatePickerOutput {
    
    func didChangeDueDate(to date: Date) {
        sprint.creationDate = date
        showStartDate(date)
    }
    
}

extension SprintCreationViewController: EditorContainerOutput {
    
    func editingFinished(viewController: UIViewController) {}
    
    func editingCancelled(viewController: UIViewController) {}
    
}
