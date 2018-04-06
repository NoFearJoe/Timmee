//
//  ListEditorInteractor.swift
//  Timmee
//
//  Created by Ilya Kharabet on 10.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.Date

protocol ListEditorInteractorInput: class {
    func createList() -> List
    func saveList(_ list: List, tasks: [Task], success: (() -> Void)?, fail: (() -> Void)?)
}

protocol ListEditorInteractorOutput: class {

}

final class ListEditorInteractor {

    weak var output: ListEditorInteractorOutput!
    
    private var listsService = ServicesAssembly.shared.listsService

}

extension ListEditorInteractor: ListEditorInteractorInput {

    func createList() -> List {
        let id = RandomStringGenerator.randomString(length: 20)
        let image = ListIcon.randomIcon
        return List(id: id,
                    title: "",
                    icon: image,
                    creationDate: Date())
    }
    
    func saveList(_ list: List, tasks: [Task], success: (() -> Void)?, fail: (() -> Void)?) {
        guard isValidList(list) else {
            fail?()
            return
        }
        
        listsService.createOrUpdateList(list, tasks: tasks) { error in
            if error != nil {
                fail?()
            } else {
                success?()
            }
        }
    }

}

fileprivate extension ListEditorInteractor {

    func isValidList(_ list: List) -> Bool {
        return !list.title.trimmed.isEmpty
    }

}
