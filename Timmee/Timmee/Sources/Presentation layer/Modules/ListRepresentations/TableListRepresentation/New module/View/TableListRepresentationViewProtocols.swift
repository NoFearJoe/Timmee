//
//  TableListRepresentationViewProtocols.swift
//  Timmee
//
//  Created by i.kharabet on 12.04.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

protocol TableListRepresentationViewInput: class {
    func showNoTasksPlaceholder()
    func hideNoTasksPlaceholder()
    
    func setEditingMode(_ mode: ListRepresentationEditingMode)
    
    func subscribeToCacheObserver(_ observer: CacheSubscribable)
    
    func resetOffset()
    
    func setInteractionsEnabled(_ isEnabled: Bool)
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
