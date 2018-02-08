//
//  SmartListPickerInteractor.swift
//  Timmee
//
//  Created by i.kharabet on 07.02.18.
//  Copyright © 2018 Mesterra. All rights reserved.
//

final class SmartListsPickerInteractor {
    
    private let listsService = ListsService()
    
    private let allSmartLists = SmartListType.allValues.filter { $0 != .all }.map { SmartList(type: $0) }
    
    func obtainSmartLists() -> [SmartList] {
        return allSmartLists
    }
    
    func obtainSelectedSmartLists() -> [SmartList] {
        return listsService.fetchSmartLists()
    }
    
    func setSmartListSelected(smartList: SmartList,
                              isSelected: Bool,
                              completion: @escaping () -> Void) {
        if isSelected {
            listsService.addSmartList(smartList, completion: { _ in completion() })
        } else {
            listsService.removeSmartList(smartList, completion: { _ in completion() })
        }
    }
    
}
