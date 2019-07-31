//
//  DiaryEntriesSubmoduleListView.swift
//  Agile diary
//
//  Created by i.kharabet on 31/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import Workset
import UIComponents

final class DiaryEntriesSubmoduleListView: AutoSizingTableView {
    
    init() {
        super.init(frame: .zero, style: .plain)
        
        registerCells()
        setupAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    private func registerCells() {
        register(DiaryEntriesSubmoduleListCell.self, forCellReuseIdentifier: DiaryEntriesSubmoduleListCell.identifier)
    }
    
    private func setupAppearance() {
        clipsToBounds = false
        tableFooterView = UIView()
        keyboardDismissMode = .onDrag
        separatorStyle = .none
        contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        isScrollEnabled = false
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }        
    }
    
}
