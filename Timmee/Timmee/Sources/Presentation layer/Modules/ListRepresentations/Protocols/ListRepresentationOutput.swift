//
//  ListRepresentationOutput.swift
//  Timmee
//
//  Created by Ilya Kharabet on 02.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

protocol ListRepresentationOutput: class {
//    func didAskToShowTaskEditor(with taskTitle: String)
//    func didAskToShowTaskEditor(with task: Task?)
    func tasksCountChanged(count: Int)
    func groupEditingOperationCompleted()
    func didPressEdit(for task: Task)
}

protocol ListRepresentationEditingOutput: class {
    func setGroupEditingActionsEnabled(_ isEnabled: Bool)
    func setCompletionGroupEditingAction(_ action: GroupEditingCompletionAction)
}
