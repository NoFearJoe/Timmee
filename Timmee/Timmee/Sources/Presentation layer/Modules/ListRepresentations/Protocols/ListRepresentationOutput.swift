//
//  ListRepresentationOutput.swift
//  Timmee
//
//  Created by Ilya Kharabet on 02.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

protocol ListRepresentationOutput: class {
    func didAskToShowTaskEditor(with taskTitle: String)
    func didAskToShowTaskEditor(with task: Task?)
}

protocol ListRepresentationEditingOutput: class {
    func groupEditingWillToggle(to isEditing: Bool)
    func groupEditingToggled(to isEditing: Bool)
    
    func didAskToShowListsForMoveTasks(completion: @escaping (List) -> Void)
    func setGroupEditingVisible(_ isVisible: Bool)
}
