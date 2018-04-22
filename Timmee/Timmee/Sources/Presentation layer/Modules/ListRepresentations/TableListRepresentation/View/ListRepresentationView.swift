//
//  ListRepresentationView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 02.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

protocol ListRepresentationViewInput: class {
    func setTaskTitleFieldFirstResponder(_ isFirstResponder: Bool)
    func clearTaskTitleInput()
    
    func setEditingMode(_ mode: ListRepresentationEditingMode)
    func setImportancy(_ isImportant: Bool)
    func setGroupEditingActionsEnabled(_ isEnabled: Bool)
    func setCompletionGroupEditingAction(_ action: GroupEditingCompletionAction)
}

protocol ListRepresentationViewOutput: class {
    func didToggleImportancyInShortTaskEditor(to isImportant: Bool)
    func didInputTaskTitle(_ title: String?)
    func didPressAddTaskButton()
    func didPressMoreButton()
}

final class ListRepresentationView: UIViewController {

    var output: ListRepresentationViewOutput!
    
    @IBOutlet private var tableContainerView: UIView!
    
    @IBOutlet private var shortTaskEditorView: UIView!
    
    private var editingMode: ListRepresentationEditingMode = .default
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableContainerView.backgroundColor = AppTheme.current.middlegroundColor
    }

}

extension ListRepresentationView: ListRepresentationViewInput {
    
    func clearTaskTitleInput() {
        
    }
    
    func setEditingMode(_ mode: ListRepresentationEditingMode) {
        self.editingMode = mode

    }
    
    func setImportancy(_ isImportant: Bool) {
        
        output.didToggleImportancyInShortTaskEditor(to: isImportant)
    }
    
    func setGroupEditingActionsEnabled(_ isEnabled: Bool) {

    }
    
    func setCompletionGroupEditingAction(_ action: GroupEditingCompletionAction) {
        
    }

    func setTaskTitleFieldFirstResponder(_ isFirstResponder: Bool) {
        
    }
    
    
    
}
