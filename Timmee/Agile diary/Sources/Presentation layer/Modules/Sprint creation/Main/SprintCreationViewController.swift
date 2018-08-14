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

final class SprintCreationViewController: UIViewController {
    
    @IBOutlet private var headerView: LargeHeaderView!
    @IBOutlet private var sectionSwitcher: Switcher!
    @IBOutlet private var addButton: UIButton!
    
    private var contentViewController: SprintContentViewController!
    
    private var currentSection = SprintCreationSection.targets
    
    var sprint: List! {
        didSet {
            contentViewController.sprintID = sprint.id
            headerView.titleLabel.text = "Sprint".localized + " #\(sprint.sortPosition)"
            showStartDate(sprint.creationDate)
        }
    }
    
    private let sprintsService = ServicesAssembly.shared.listsService
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.leftButton?.isHidden = sprint == nil
        sectionSwitcher.items = [SprintCreationSection.targets.title, SprintCreationSection.habits.title]
        sectionSwitcher.selectedItemIndex = 0
        sectionSwitcher.addTarget(self, action: #selector(onSwitchSection), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getOrCreateExistingSprintIfNeeded()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SprintContent" {
            contentViewController = segue.destination as! SprintContentViewController
            contentViewController.section = currentSection
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func showStartDate(_ date: Date) {
        let resultStirng = NSMutableAttributedString(string: "Начало ")
        let dateString = NSAttributedString(string: date.asNearestShortDateString.lowercased(), attributes: [.foregroundColor: UIColor.blue])
        resultStirng.append(dateString)
        headerView.subtitleLabel.attributedText = resultStirng
    }
    
    @objc private func onSwitchSection() {
        currentSection = SprintCreationSection(rawValue: sectionSwitcher.selectedItemIndex) ?? .targets
        contentViewController.section = currentSection
    }
    
    @IBAction private func onClose() {
        // Alert, then close
    }
    
    @IBAction private func onAdd() {
        switch currentSection {
        case .targets: break
        case .habits: break
        }
    }
    
    @IBAction private func onDone() {
        // Alert, then set list.note = "", then save, then close
    }
    
    private func getOrCreateExistingSprintIfNeeded() {
        if sprint == nil {
            let existingSprints = sprintsService.fetchLists()
            if let temporarySprint = existingSprints.first(where: { $0.note == "temporary" }) {
                sprint = temporarySprint
            } else {
                let latestSprint = existingSprints.max(by: { $0.sortPosition < $1.sortPosition })
                let nextSprintNumber = (latestSprint?.sortPosition ?? 0) + 1
                let sprint = Sprint(number: nextSprintNumber)
                sprintsService.createOrUpdateList(sprint, tasks: []) { [weak self] _ in
                    self?.sprint = sprint
                }
            }
        }
    }
    
}
