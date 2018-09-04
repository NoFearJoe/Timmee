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

final class SprintCreationViewController: UIViewController, SprintInteractorTrait {
    
    @IBOutlet private var headerView: LargeHeaderView!
    @IBOutlet private var sectionSwitcher: Switcher!
    @IBOutlet private var addButton: UIButton!
    
    private var contentViewController: SprintContentViewController!
    
    private var currentSection = SprintCreationSection.habits
    
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
        sectionSwitcher.items = [SprintCreationSection.habits.title, SprintCreationSection.targets.title]
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
        }else {
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
        currentSection = SprintCreationSection(rawValue: sectionSwitcher.selectedItemIndex) ?? .habits
        contentViewController.section = currentSection
    }
    
    @IBAction private func onClose() {
        // Alert, then close
    }
    
    @IBAction private func onAdd() {
        switch currentSection {
        case .targets: performSegue(withIdentifier: "ShowTargetCreation", sender: nil)
        case .habits: performSegue(withIdentifier: "ShowHabitCreation", sender: nil)
        }
    }
    
    @IBAction private func onDone() {
        // Alert, then set list.note = "", then save, then close
        sprint.note = ""
        saveSprint(sprint) { [weak self] success in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    func setupDoneButton() {
        headerView.rightButton?.setTitleColor(AppTheme.current.colors.inactiveElementColor, for: .disabled)
        headerView.rightButton?.setTitleColor(AppTheme.current.colors.mainElementColor, for: .normal)
    }
    
}
