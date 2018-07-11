//
//  TableListRepresentationViewProtocols.swift
//  Timmee
//
//  Created by i.kharabet on 12.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import struct Foundation.IndexPath

protocol TableListRepresentationViewInput: AlertInput {
    func showNoTasksPlaceholder()
    func hideNoTasksPlaceholder()
    
    func setEditingMode(_ mode: ListRepresentationEditingMode, completion: @escaping () -> Void)
    
    func subscribeToCacheObserver(_ observer: CacheSubscribable)
    
    func resetOffset()
    
    func setInteractionsEnabled(_ isEnabled: Bool)
    
    func animateModification(at indexPath: IndexPath)
}

protocol TableListRepresentationViewOutput: class {
    func viewWillAppear()
}

protocol TableListRepresentationDataSource: class {
    func sectionsCount() -> Int
    func itemsCount(in section: Int) -> Int
    func item(at index: Int, in section: Int) -> Task?
    func sectionInfo(forSectionAt index: Int) -> (name: String, numberOfItems: Int)?
    func sectionInfo(forSectionWithName name: String) -> (name: String, numberOfItems: Int)?
    func totalObjectsCount() -> Int
}
