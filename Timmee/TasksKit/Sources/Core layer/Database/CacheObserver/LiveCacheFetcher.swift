//
//  LiveCacheFetcher.swift
//  TasksKit
//
//  Created by Илья Харабет on 30/12/2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import CoreData
import Dwifft

public struct CachedEntitiesObserverDelegate<Entity: Equatable> {
    let onInitialFetch: (([String: [Entity]]) -> Void)?
    let onEntitiesCountChange: ((Int) -> Void)?
    let onChanges: (([CoreDataChange]) -> Void)?
    let onBatchUpdatesCompleted: (() -> Void)?
    public init(onInitialFetch: (([String: [Entity]]) -> Void)? = nil,
                onEntitiesCountChange: ((Int) -> Void)? = nil,
                onChanges: (([CoreDataChange]) -> Void)? = nil,
                onBatchUpdatesCompleted: (() -> Void)? = nil) {
        self.onInitialFetch = onInitialFetch
        self.onEntitiesCountChange = onEntitiesCountChange
        self.onChanges = onChanges
        self.onBatchUpdatesCompleted = onBatchUpdatesCompleted
    }
}

/// Своя реализация NSFetchedResultsController, позволяющая более гибко разбивать сущности на секции и фильтровать их
public final class CachedEntitiesObserver<ManagedObject: NSManagedObject, Entity: Equatable & CustomEquatable & Copyable>: CacheSubscribable where Entity.T == Entity {
    
    public typealias Observer = ([String: [Entity]]) -> Void
    
    let context: NSManagedObjectContext
    let baseRequest: NSFetchRequest<ManagedObject>
    let grouping: ((Entity) throws -> String)?
    let mapping: (ManagedObject) -> Entity
    let filter: ((Entity) -> Bool)?
    let sectionsOffset: Int
    
    var delegate: CachedEntitiesObserverDelegate<Entity>!
    private weak var subscriber: CacheSubscriber?
    
    private let processingQueue = DispatchQueue(label: "cached_entities_observer_processing_queue")
    
    private var currentSectionedEntities: [String: [Entity]] = [:]
    private var currentSectionedValues: SectionedValues<String, Entity> = .init()
    
    private var isSubscribedToChanges = false
    
    public init(context: NSManagedObjectContext,
                baseRequest: NSFetchRequest<ManagedObject>,
                grouping: ((Entity) throws -> String)? = nil,
                mapping: @escaping (ManagedObject) -> Entity,
                filter: ((Entity) -> Bool)? = nil,
                sectionsOffset: Int = 0) {
        self.context = context
        self.baseRequest = baseRequest
        self.grouping = grouping
        self.mapping = mapping
        self.filter = filter
        self.sectionsOffset = sectionsOffset
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func setDelegate(_ delegate: CachedEntitiesObserverDelegate<Entity>) {
        self.delegate = delegate
    }
    
    public func setSubscriber(_ subscriber: CacheSubscriber) {
        self.subscriber = subscriber
    }
    
    public func fetch() {
        guard let fetchResult = try? self.context.fetch(self.baseRequest) else {
            self.currentSectionedEntities = [:]
            self.delegate.onInitialFetch?([:])
            self.delegate.onEntitiesCountChange?(0)
            self.subscriber?.reloadData()
            return
        }
        
        subscribeToChangesInContext()
        
        processingQueue.async {
            var entities: [Entity] = []
            self.context.performAndWait {
                entities = fetchResult.compactMap(self.mapping)
            }
            
            let filteredEntities = self.filter.flatMap { entities.filter($0) } ?? entities
            
            let sectionedEntities: [String: [Entity]]
            if let grouping = self.grouping {
                sectionedEntities = (try? Dictionary<String, [Entity]>(grouping: filteredEntities, by: grouping)) ?? [:]
            } else {
                sectionedEntities = filteredEntities.isEmpty ? [:] : ["": filteredEntities]
            }
            
            let sectionedValues = SectionedValues<String, Entity>(sectionedEntities.map({ ($0, $1) }).sorted(by: { $0.0 < $1.0 }))
            
            if self.currentSectionedValues.sectionsAndValues.isEmpty {
                DispatchQueue.main.async {
                    self.currentSectionedEntities = sectionedEntities
                    self.currentSectionedValues = sectionedValues
                    self.delegate.onInitialFetch?(sectionedEntities)
                    self.delegate.onEntitiesCountChange?(self.totalObjectsCount())
                    self.subscriber?.reloadData()
                }
            } else {
                let diff = Dwifft.diff(lhs: self.currentSectionedValues, rhs: sectionedValues)
//                let coreDataChanges = diff.map(self.mapDwifftStepToCoreDataChange)
                let coreDataChanges = self.mapStepsToChanges(from: diff)
                DispatchQueue.main.async {
                    self.subscriber?.prepareToProcessChanges()
                    self.currentSectionedEntities = sectionedEntities
                    self.currentSectionedValues = sectionedValues
                    self.delegate.onEntitiesCountChange?(self.totalObjectsCount())
                    self.subscriber?.processChanges(coreDataChanges) {
                        self.delegate.onChanges?(coreDataChanges)
                        self.delegate.onBatchUpdatesCompleted?()
                    }
                }
            }
        }
    }
    
    private func subscribeToChangesInContext() {
        guard !isSubscribedToChanges else { return }
        isSubscribedToChanges = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onChangeInContext(_:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: context)
    }
    
    @objc private func onChangeInContext(_ notification: Notification) {
        fetch()
    }
    
    private func mapDwifftStepToCoreDataChange(_ step: SectionedDiffStep<String, Entity>) -> CoreDataChange {
        switch step {
        case let .sectionInsert(index, _):
            return CoreDataChange.sectionInsertion(index + sectionsOffset)
        case let .sectionDelete(index, _):
            return CoreDataChange.sectionDeletion(index + sectionsOffset)
        case let .insert(section, row, _):
            return CoreDataChange.insertion(IndexPath(row: row, section: section + sectionsOffset))
        case let .delete(section, row, _):
            return CoreDataChange.deletion(IndexPath(row: row, section: section + sectionsOffset))
        }
    }
    
//    private func mapStepsToChanges(from steps: [SectionedDiffStep<String, Entity>]) -> [CoreDataChange] {
//        var result: [CoreDataChange] = []
//        var temporaryUpdatesOrMoves: [CoreDataChange] = []
//        steps.enumerated().forEach { index, step in
//            switch step {
//            case .sectionInsert, .sectionDelete:
//                result.append(mapDwifftStepToCoreDataChange(step))
//            case let .insert(section, row, _):
//                let indexPath = IndexPath(row: row, section: section + sectionsOffset)
//                if let temporaryChange = temporaryUpdatesOrMoves.first(where: { $0.isEqualByIndexPath(with: indexPath) }) {
//                    result.append(temporaryChange)
//                    temporaryUpdatesOrMoves.removeAll(where: { $0.isEqualByIndexPath(with: indexPath) })
//                } else {
//                    result.append(.insertion(indexPath))
//                }
//            case let .delete(section, row, value):
//                let indexPath = IndexPath(row: row, section: section + sectionsOffset)
//                if let inserted = steps.first(where: { $0.isInsertion && ($0.value == value || $0.value?.isEqual(to: value) == true) }),
//                   !steps.contains(where: { $0.isSectionInsertion && $0.sectionIndex == section + sectionsOffset }) {
//                    let insertedChange = mapDwifftStepToCoreDataChange(inserted)
//                    if insertedChange.indexPath == indexPath {
//                        temporaryUpdatesOrMoves.append(.update(indexPath))
//                    } else {
//                        temporaryUpdatesOrMoves.append(.move(indexPath, insertedChange.indexPath!))
//                    }
//                } else {
//                    result.append(.deletion(indexPath))
//                }
//            }
//        }
//        return result
//    }
    
    private func mapStepsToChanges(from steps: [SectionedDiffStep<String, Entity>]) -> [CoreDataChange] {
        // Собрать изменения
        var changesByEntity: [(Any, [CoreDataChange])] = []
        steps.forEach { step in
            let change = self.mapDwifftStepToCoreDataChange(step)
            guard let key: Any = step.value ?? step.section else { return }
            if changesByEntity.first(where: { $0.0 }) {
                changesByEntity[key] = [change]
            } else {
                changesByEntity[key]!.append(change)
            }
        }
        
        // Преобразовать изменения в move, update...
        var mappedChangesByEntity: [(Any, CoreDataChange)] = []
        changesByEntity.forEach { key, value in
            switch value {
            case let changes where changes.count == 1:
                mappedChangesByEntity[key] = changes.first!
            case let changes where changes.count == 2:
                switch (changes[0], changes[1]) {
                case let (.deletion(deletionIndex), .insertion(insertionIndex)), let (.insertion(insertionIndex), .deletion(deletionIndex)):
                    if deletionIndex == insertionIndex {
                        mappedChangesByEntity[key] = .update(insertionIndex)
                    } else {
                        mappedChangesByEntity[key] = .move(deletionIndex, insertionIndex)
                    }
                default:
                    mappedChangesByEntity[key] = changes.first!
                }
            default: break
            }
        }
        
        // вернуть массив изменений
        return mappedChangesByEntity.map { $0.value }
    }
    
}

extension CachedEntitiesObserver {
    
    public func numberOfSections() -> Int {
        return currentSectionedEntities.count
    }
    
    public func numberOfItems(in section: Int) -> Int {
        guard let section = currentSectionedValues.sectionsAndValues.item(at: section - sectionsOffset) else { return 0 }
        return section.1.count
    }
    
    public func item(at indexPath: IndexPath) -> Entity? {
        return currentSectionedValues.sectionsAndValues.item(at: indexPath.section - sectionsOffset)?.1.item(at: indexPath.row)?.copy
    }
    
    public func items(in section: Int) -> [Entity] {
        return currentSectionedValues.sectionsAndValues.item(at: section - sectionsOffset)?.1.map { $0.copy } ?? []
    }
    
//    public func entity(at indexPath: IndexPath) -> NSManagedObject {
//        var indexPathWithOffset = indexPath
//        indexPathWithOffset.section -= sectionOffset
//
//        return fetchedResultsController.object(at: indexPathWithOffset) as! NSManagedObject
//    }
    
    public func indexPath(of item: Entity) -> IndexPath? {
        guard let section = currentSectionedValues.sectionsAndValues.firstIndex(where: { $0.1.contains(item) }) else { return nil }
        guard let index = currentSectionedValues.sectionsAndValues.item(at: section)?.1.index(of: item) else { return nil }
        return IndexPath(row: index, section: section)
    }
    
    public func allObjects() -> [Entity] {
        return currentSectionedValues.sectionsAndValues.flatMap { $0.1 }
    }
    
    public func totalObjectsCount() -> Int {
        return (0..<numberOfSections()).reduce(0) { (result, section) in
            return result + self.numberOfItems(in: section)
        }
    }
    
    public func containsSection(withName name: String) -> Bool {
        return sectionInfo(with: name) != nil
    }
    
    public func sectionInfo(with sectionName: String) -> (name: String, numberOfItems: Int)? {
        guard let sectionInfo = currentSectionedValues.sectionsAndValues.first(where: { $0.0 == sectionName }) else { return nil }
        return (sectionInfo.0, sectionInfo.1.count)
    }
    
    public func sectionInfo(at index: Int) -> (name: String, numberOfItems: Int)? {
        guard let sectionInfo = currentSectionedValues.sectionsAndValues.item(at: index - sectionsOffset) else { return nil }
        return (sectionInfo.0, sectionInfo.1.count)
    }
    
}

fileprivate extension SectionedDiffStep {
    
    var value: Value? {
        switch self {
        case let .insert(_, _, value), let .delete(_, _, value):
            return value
        default:
            return nil
        }
    }
    
    var section: Section? {
        switch self {
        case let .sectionInsert(_, section), let .sectionDelete(_, section):
            return section
        default:
            return nil
        }
    }
    
    var sectionIndex: Int? {
        switch self {
        case let .sectionInsert(index, _), let .sectionDelete(index, _):
            return index
        default:
            return nil
        }
    }
    
    var isDeletion: Bool {
        if case .delete = self {
            return true
        }
        return false
    }
    
    var isInsertion: Bool {
        if case .insert = self {
            return true
        }
        return false
    }
    
    var isSectionInsertion: Bool {
        if case .sectionInsert = self {
            return true
        }
        return false
    }
    
}

extension SectionedDiffStep: Equatable where Value: Equatable, Section: Equatable {
    public static func == (lhs: SectionedDiffStep, rhs: SectionedDiffStep) -> Bool {
        switch (lhs, rhs) {
        case let (.insert(lhsRow, lhsSection, lhsValue), .insert(rhsRow, rhsSection, rhsValue)):
            return lhsRow == rhsRow && lhsSection == rhsSection && lhsValue == rhsValue
        case let (.delete(lhsRow, lhsSection, lhsValue), .delete(rhsRow, rhsSection, rhsValue)):
            return lhsRow == rhsRow && lhsSection == rhsSection && lhsValue == rhsValue
        case let (.sectionInsert(lhsSection, lhsValue), .sectionInsert(rhsSection, rhsValue)):
            return lhsSection == rhsSection && lhsValue == rhsValue
        case let (.sectionDelete(lhsSection, lhsValue), .sectionDelete(rhsSection, rhsValue)):
            return lhsSection == rhsSection && lhsValue == rhsValue
        default:
            return false
        }
    }
}
