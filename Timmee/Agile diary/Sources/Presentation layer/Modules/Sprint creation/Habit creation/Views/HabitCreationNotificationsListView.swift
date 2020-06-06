//
//  HabitCreationNotificationsListView.swift
//  Agile diary
//
//  Created by Илья Харабет on 05/06/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import UIComponents
import SwipeCellKit

final class HabitCreationNotificationsListView: AutoSizingTableView {
    
    var onTapDeleteButton: ((Int) -> Void)?
    
    private var models: [String] = []
    
    init() {
        super.init(frame: .zero, style: .plain)
        
        delegate = self
        dataSource = self
        separatorStyle = .none
        delaysContentTouches = false
        showsVerticalScrollIndicator = false
        
        register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func reload(with models: [String]) {
        self.models = models
        reloadData()
    }
    
    @objc private func onTapDeleteButton(_ button: UIButton) {
        onTapDeleteButton?(button.tag)
    }
    
}

extension HabitCreationNotificationsListView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = models[indexPath.row]
        cell.textLabel?.font = AppTheme.current.fonts.regular(17)
        cell.textLabel?.textColor = AppTheme.current.colors.activeElementColor
        
        let button = UIButton(type: .custom)
        button.tintColor = AppTheme.current.colors.wrongElementColor
        button.setImage(UIImage(named: "trash"), for: .normal)
        button.addTarget(self, action: #selector(onTapDeleteButton(_:)), for: .touchUpInside)
        button.tag = indexPath.row
        button.bounds.size = CGSize(width: 32, height: 32)
        cell.accessoryView = button
        
        cell.selectionStyle = .none
                
        return cell
    }
    
}

extension HabitCreationNotificationsListView: UITableViewDelegate {}
