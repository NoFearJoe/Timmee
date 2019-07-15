//
//  GroupEditingPanelViewController.swift
//  Timmee
//
//  Created by i.kharabet on 13.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

protocol GroupEditingPanelInput: class {
    func show()
    func hide()
    func setActionsEnabled(_ isEnabled: Bool)
    func updateCompletionAction(with action: GroupEditingCompletionAction)
}

protocol GroupEditingPanelOutput: class {
    func didSelectGroupEditingAction(_ action: GroupEditingAction)
}

final class GroupEditingPanelViewController: UIViewController {
    
    weak var output: GroupEditingPanelOutput!
    
    @IBOutlet private var actionsView: GroupEditingActionsView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        actionsView.onAction = { [unowned self] action in
            self.output.didSelectGroupEditingAction(action)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        actionsView.setVisible(false, animated: false)
    }
    
}

extension GroupEditingPanelViewController: GroupEditingPanelInput {
    
    func show() {
        actionsView.setEnabled(false)
        actionsView.setVisible(true, animated: true)
    }
    
    func hide() {
        actionsView.setVisible(false, animated: true)
    }
    
    func setActionsEnabled(_ isEnabled: Bool) {
        actionsView.setEnabled(isEnabled)
    }
    
    func updateCompletionAction(with action: GroupEditingCompletionAction) {
        actionsView.updateAction(.complete,
                                 withTitle: action.title,
                                 andImage: action.image)
    }
    
}
