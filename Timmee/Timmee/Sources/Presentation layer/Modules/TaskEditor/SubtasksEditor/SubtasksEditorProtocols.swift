//
//  SubtasksEditorProtocols.swift
//  Timmee
//
//  Created by i.kharabet on 13.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

protocol SubtasksEditorOutput: class {
    func addSubtask(with title: String)
    func updateSubtask(at index: Int, newTitle: String)
    func removeSubtask(at index: Int)
    func exchangeSubtasks(at indexes: (Int, Int))
    func doneSubtask(at index: Int)
}

protocol SubtasksEditorDataSource: class {
    func subtasksCount() -> Int
    func subtask(at index: Int) -> Subtask?
}

protocol SubtasksEditorInteractorOutput: class {
    func subtasksInserted(at indexes: [Int])
    func subtasksRemoved(at indexes: [Int])
    func subtasksUpdated(at indexes: [Int])
}

protocol SubtasksEditorTaskProvider: class {
    var task: Task! { get }
}
