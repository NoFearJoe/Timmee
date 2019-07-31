//
//  DiaryEntriesSubmoduleView.swift
//  Agile diary
//
//  Created by i.kharabet on 31/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import Workset
import TasksKit
import UIComponents

final class DiaryEntriesSubmoduleView: UIView {
    
    var onAddEntry: (() -> Void)?
    
    private let diaryEntriesListView = DiaryEntriesSubmoduleListView()
    private let addEntryButton = UIButton(type: .custom)
    
    private let diaryService = ServicesAssembly.shared.diaryService
    
    private var diaryEntries: [DiaryEntry] = []
    
    private let maxEntriesCount: Int
    
    init(maxEntriesCount: Int) {
        self.maxEntriesCount = maxEntriesCount
        
        super.init(frame: .zero)
        
        setupSubviews()
        setupConstraints()
        
        clipsToBounds = false
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    func configure(attachmentType: DiaryEntryAttachmentType, entity: Any) {
        let allDiaryEntries: [DiaryEntry]
        switch attachmentType {
        case .habit:
            guard let habit = entity as? Habit else { return }
            allDiaryEntries = diaryService.fetchDiaryEntries(habit: habit)
        case .goal:
            guard let goal = entity as? Goal else { return }
            allDiaryEntries = diaryService.fetchDiaryEntries(goal: goal)
        case .sprint:
            guard let sprint = entity as? Sprint else { return }
            allDiaryEntries = diaryService.fetchDiaryEntries(sprint: sprint)
        }
        
        let limitedDiaryEntries = Array(allDiaryEntries.prefix(maxEntriesCount))
        self.diaryEntries = limitedDiaryEntries
        
        diaryEntriesListView.reloadData()
    }
    
    private func setupSubviews() {
        addSubview(diaryEntriesListView)
        diaryEntriesListView.dataSource = self
        
        addSubview(addEntryButton)
        addEntryButton.setTitle("add_diary_entry".localized, for: .normal)
        addEntryButton.setTitleColor(AppTheme.current.colors.mainElementColor, for: .normal)
        addEntryButton.addTarget(self, action: #selector(onTapToAddEntryButton), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        [diaryEntriesListView.leading(), diaryEntriesListView.top(), diaryEntriesListView.trailing()].toSuperview()
        
        [addEntryButton.leading(), addEntryButton.bottom()].toSuperview()
        addEntryButton.height(36)
        
        addEntryButton.topToBottom().to(diaryEntriesListView, addTo: self)
    }
    
    @objc private func onTapToAddEntryButton() {
        onAddEntry?()
    }
    
}

extension DiaryEntriesSubmoduleView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diaryEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DiaryEntriesSubmoduleListCell.identifier,
                                                 for: indexPath) as! DiaryEntriesSubmoduleListCell
        if let diaryEntry = diaryEntries.item(at: indexPath.row) {
            cell.configure(model: diaryEntry)
        }
        return cell
    }
    
}
