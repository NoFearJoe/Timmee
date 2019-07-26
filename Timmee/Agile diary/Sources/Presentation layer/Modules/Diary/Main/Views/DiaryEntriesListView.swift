//
//  DiaryEntriesListView.swift
//  Agile diary
//
//  Created by i.kharabet on 26/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import Workset
import UIComponents

final class DiaryEntriesListView: UITableView {
    
    init() {
        super.init(frame: .zero, style: .plain)
        
        registerCells()
        setupAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    private func registerCells() {
        register(DiaryEntryCell.self, forCellReuseIdentifier: DiaryEntryCell.identifier)
    }
    
    private func setupAppearance() {
        tableFooterView = UIView()
        keyboardDismissMode = .onDrag
        separatorStyle = .none
        contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
        
        transform = CGAffineTransform(scaleX: 1, y: -1)
        
    }
    
}
