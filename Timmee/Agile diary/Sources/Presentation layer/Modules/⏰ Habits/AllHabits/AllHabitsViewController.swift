//
//  AllHabitsViewController.swift
//  Agile diary
//
//  Created by Илья Харабет on 27.05.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import Workset
import TasksKit
import UIComponents

final class AllHabitsViewController: BaseViewController {
    
    // MARK: - UI
    
    private let habitsListView = UITableView(
        frame: .zero,
        style: .plain
    )
    
    // MARK: - Services
    
    private let habitsService = ServicesAssembly.shared.habitsService
    
    // MARK: - State
    
    private let sprint: Sprint
    private var habits: [Habit] = []
    
    // MARK: - Functions
    
    init(sprint: Sprint) {
        self.sprint = sprint
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func prepare() {
        super.prepare()
        
        setupViews()
    }
    
    override func refresh() {
        super.refresh()
        
        reloadHabits()
    }
    
    private func reloadHabits() {
        habits = habitsService.fetchHabits(sprintID: sprint.id)
        habitsListView.reloadData()
    }
    
}

extension AllHabitsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        habits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
        
        cell.configure(habit: habits[indexPath.row], onDelete: { [unowned self, unowned tableView, unowned cell] in
            guard let index = tableView.indexPath(for: cell) else { return }
            guard let habit = self.habits.item(at: index.row) else { return }
            
            self.habitsService.removeHabit(habit) { [weak self] success in
                guard success else { return }
                
                self?.reloadHabits()
            }
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let habit = habits.item(at: indexPath.row) else { return }
        
        let editor = ViewControllersFactory.habitEditor
        editor.setHabit(habit, sprint: sprint, goalID: nil)
        editor.setEditingMode(.short)
        
        present(editor, animated: true, completion: nil)
    }
    
}

private extension AllHabitsViewController {
    
    func setupViews() {
        view.backgroundColor = AppTheme.current.colors.middlegroundColor
        
        habitsListView.delegate = self
        habitsListView.dataSource = self
        habitsListView.contentInset.top = 12
        habitsListView.contentInset.bottom = 12
        habitsListView.estimatedRowHeight = 52
        habitsListView.rowHeight = UITableView.automaticDimension
        habitsListView.separatorStyle = .none
        habitsListView.backgroundColor = .clear  
        habitsListView.showsVerticalScrollIndicator = false
        habitsListView.register(Cell.self, forCellReuseIdentifier: Cell.reuseIdentifier)
        view.addSubview(habitsListView)
        habitsListView.allEdges().toSuperview()
    }
    
}
