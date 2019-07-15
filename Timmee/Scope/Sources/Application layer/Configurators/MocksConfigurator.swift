//
//  MocksConfigurator.swift
//  Scope
//
//  Created by i.kharabet on 03/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import Foundation
import TasksKit

final class RuMocksConfigurator {
    
    let listsService = ServicesAssembly.shared.listsService
    let tasksService = ServicesAssembly.shared.tasksService
    let subtasksService = ServicesAssembly.shared.subtasksService
    let tagsService = ServicesAssembly.shared.tagsService
    
    func configure(completion: @escaping () -> Void) {
        // Lists
        
        let l1 = List(id: "l1", title: "Мой проект", icon: .job, creationDate: Date())
        l1.isFavorite = true
        let l2 = List(id: "l2", title: "Книги, фильмы, музыка, игры", icon: .games, creationDate: Date())
        let l3 = List(id: "l3", title: "Тренировки", icon: .group, creationDate: Date())
        l3.isFavorite = true
        let l4 = List(id: "l4", title: "Дом", icon: .home, creationDate: Date())
        let l5 = List(id: "l5", title: "Цели на год", icon: .idea, creationDate: Date())
        
        // Tags
        let tag1 = Tag(id: "tag1", title: "Здоровье", color: AppTheme.current.tagColors[5])
        let tag2 = Tag(id: "tag2", title: "Важно", color: AppTheme.current.tagColors[0])
        
        // Tasks
        
        let t1 = Task(id: "t1", kind: .single, title: "Посмотреть последний эпизод Звездных войн", isImportant: true, notification: .doNotNotify, notificationDate: nil, notificationTime: nil, note: "", link: "", repeating: .init(type: .never), repeatEndingDate: nil, dueDate: nil, location: nil, address: nil, shouldNotifyAtLocation: false, attachments: [], isDone: false, inProgress: false, creationDate: Date(), doneDates: [])
        
        let t2 = Task(id: "t2", kind: .single, title: "Прочитать \"Над пропастью во ржи\"", isImportant: false, notification: .doNotNotify, notificationDate: nil, notificationTime: nil, note: "", link: "", repeating: .init(type: .never), repeatEndingDate: nil, dueDate: Date() + 1.asDays, location: nil, address: nil, shouldNotifyAtLocation: false, attachments: [], isDone: false, inProgress: false, creationDate: Date(), doneDates: [])
        
        let t3 = Task(id: "t3", kind: .regular, title: "Позаниматься своим проектом", isImportant: false, notification: .justInTime, notificationDate: nil, notificationTime: nil, note: "", link: "", repeating: .init(type: .every(.day)), repeatEndingDate: nil, dueDate: Date(), location: nil, address: nil, shouldNotifyAtLocation: false, attachments: [], isDone: false, inProgress: false, creationDate: Date(), doneDates: [])
        
        let t4 = Task(id: "t4", kind: .single, title: "Сходить за продуктами", isImportant: true, notification: .doNotNotify, notificationDate: nil, notificationTime: nil, note: "", link: "", repeating: .init(type: .never), repeatEndingDate: nil, dueDate: Date() + 2.asHours, location: nil, address: nil, shouldNotifyAtLocation: false, attachments: [], isDone: false, inProgress: false, creationDate: Date(), doneDates: [])
        t4.tags = [tag2]
        let s1t4 = Subtask(id: "s1t4", title: "Хлеб", isDone: true, sortPosition: 0, creationDate: Date())
        let s2t4 = Subtask(id: "s2t4", title: "Молоко", isDone: true, sortPosition: 1, creationDate: Date())
        let s3t4 = Subtask(id: "s3t4", title: "Яйца", isDone: true, sortPosition: 2, creationDate: Date())
        let s4t4 = Subtask(id: "s4t4", title: "Шоколадка", isDone: true, sortPosition: 3, creationDate: Date())
        let s5t4 = Subtask(id: "s5t4", title: "Картошка 5кг", isDone: false, sortPosition: 4, creationDate: Date())
        let s6t4 = Subtask(id: "s6t4", title: "Лук", isDone: false, sortPosition: 5, creationDate: Date())
        let s7t4 = Subtask(id: "s7t4", title: "Мясо 1кг", isDone: false, sortPosition: 6, creationDate: Date())
        let s8t4 = Subtask(id: "s8t4", title: "Сметана", isDone: false, sortPosition: 7, creationDate: Date())
        
        let t5 = Task(id: "t5", kind: .single, title: "Терапевт", isImportant: true, notification: .till1day, notificationDate: nil, notificationTime: (19, 40), note: "", link: "", repeating: .init(type: .never), repeatEndingDate: nil, dueDate: Date() + 2.asDays, location: nil, address: nil, shouldNotifyAtLocation: false, attachments: [], isDone: false, inProgress: false, creationDate: Date(), doneDates: [])
        t5.tags = [tag1]
        
        let t6 = Task(id: "t6", kind: .single, title: "Занятие с тренером", isImportant: false, notification: .till1hour, notificationDate: nil, notificationTime: nil, note: "", link: "", repeating: .init(type: .never), repeatEndingDate: nil, dueDate: Date() + 4.asDays - 2.asHours, location: nil, address: nil, shouldNotifyAtLocation: false, attachments: [], isDone: false, inProgress: false, creationDate: Date(), doneDates: [])
        
        let t7 = Task(id: "t7", kind: .single, title: "Купить спортивное питание", isImportant: false, notification: .doNotNotify, notificationDate: nil, notificationTime: nil, note: "", link: "", repeating: .init(type: .never), repeatEndingDate: nil, dueDate: Date() - 4.asDays, location: nil, address: nil, shouldNotifyAtLocation: false, attachments: [], isDone: true, inProgress: false, creationDate: Date(), doneDates: [])
        t7.tags = [tag2]
        
        let t8 = Task(id: "t8", kind: .single, title: "Забрать молоток у соседа", isImportant: true, notification: .doNotNotify, notificationDate: nil, notificationTime: nil, note: "", link: "", repeating: .init(type: .never), repeatEndingDate: nil, dueDate: nil, location: nil, address: nil, shouldNotifyAtLocation: false, attachments: [], isDone: false, inProgress: false, creationDate: Date(), doneDates: [])
        
        let t9 = Task(id: "t9", kind: .single, title: "Починить машину", isImportant: true, notification: .doNotNotify, notificationDate: nil, notificationTime: nil, note: "", link: "", repeating: .init(type: .never), repeatEndingDate: nil, dueDate: nil, location: nil, address: nil, shouldNotifyAtLocation: false, attachments: [], isDone: false, inProgress: false, creationDate: Date(), doneDates: [])
        
        let t10 = Task(id: "t10", kind: .single, title: "Купить новую машину", isImportant: false, notification: .doNotNotify, notificationDate: nil, notificationTime: nil, note: "", link: "", repeating: .init(type: .never), repeatEndingDate: nil, dueDate: nil, location: nil, address: nil, shouldNotifyAtLocation: false, attachments: [], isDone: false, inProgress: false, creationDate: Date(), doneDates: [])
        
        let t11 = Task(id: "t11", kind: .single, title: "Скачать Star Craft", isImportant: false, notification: .doNotNotify, notificationDate: nil, notificationTime: nil, note: "", link: "", repeating: .init(type: .never), repeatEndingDate: nil, dueDate: nil, location: nil, address: nil, shouldNotifyAtLocation: false, attachments: [], isDone: true, inProgress: false, creationDate: Date(), doneDates: [])
        
        let t12 = Task(id: "t12", kind: .single, title: "Послушать Metallica - Nothing else matters", isImportant: false, notification: .doNotNotify, notificationDate: nil, notificationTime: nil, note: "", link: "", repeating: .init(type: .never), repeatEndingDate: nil, dueDate: nil, location: nil, address: nil, shouldNotifyAtLocation: false, attachments: [], isDone: false, inProgress: false, creationDate: Date(), doneDates: [])
        
        // Save
        
        let group = DispatchGroup()
        
        DispatchQueue.global().async {
            
            // Tags
            
            group.enter()
            self.tagsService.createOrUpdateTag(tag1) {
                group.leave()
            }
            group.enter()
            self.tagsService.createOrUpdateTag(tag2) {
                group.leave()
            }
            
            group.wait()
            
            // Lists
            
            group.enter()
            self.listsService.createOrUpdateList(l1, tasks: []) { _ in
                group.leave()
            }
            group.enter()
            self.listsService.createOrUpdateList(l2, tasks: []) { _ in
                group.leave()
            }
            group.enter()
            self.listsService.createOrUpdateList(l3, tasks: []) { _ in
                group.leave()
            }
            group.enter()
            self.listsService.createOrUpdateList(l4, tasks: []) { _ in
                group.leave()
            }
            group.enter()
            self.listsService.createOrUpdateList(l5, tasks: []) { _ in
                group.leave()
            }
            
            group.wait()
            
            // Tasks
            
            group.enter()
            self.tasksService.addTask(t1, listID: l2.id) { _ in
                group.leave()
            }
            group.enter()
            self.tasksService.addTask(t2, listID: l2.id) { _ in
                group.leave()
            }
            group.enter()
            self.tasksService.addTask(t3, listID: l1.id) { _ in
                group.leave()
            }
            group.enter()
            self.tasksService.addTask(t4, listID: SmartListType.all.id) { _ in
                group.leave()
            }
            group.enter()
            self.tasksService.addTask(t5, listID: SmartListType.all.id) { _ in
                group.leave()
            }
            group.enter()
            self.tasksService.addTask(t6, listID: l3.id) { _ in
                group.leave()
            }
            group.enter()
            self.tasksService.addTask(t7, listID: l3.id) { _ in
                group.leave()
            }
            group.enter()
            self.tasksService.addTask(t8, listID: l4.id) { _ in
                group.leave()
            }
            group.enter()
            self.tasksService.addTask(t9, listID: l4.id) { _ in
                group.leave()
            }
            group.enter()
            self.tasksService.addTask(t10, listID: l5.id) { _ in
                group.leave()
            }
            group.enter()
            self.tasksService.addTask(t11, listID: l2.id) { _ in
                group.leave()
            }
            group.enter()
            self.tasksService.addTask(t12, listID: l2.id) { _ in
                group.leave()
            }
            
            group.wait()
            
            // Subtasks
            
            group.enter()
            self.subtasksService.addSubtask(s1t4, to: t4) {
                group.leave()
            }
            group.enter()
            self.subtasksService.addSubtask(s2t4, to: t4) {
                group.leave()
            }
            group.enter()
            self.subtasksService.addSubtask(s3t4, to: t4) {
                group.leave()
            }
            group.enter()
            self.subtasksService.addSubtask(s4t4, to: t4) {
                group.leave()
            }
            group.enter()
            self.subtasksService.addSubtask(s5t4, to: t4) {
                group.leave()
            }
            group.enter()
            self.subtasksService.addSubtask(s6t4, to: t4) {
                group.leave()
            }
            group.enter()
            self.subtasksService.addSubtask(s7t4, to: t4) {
                group.leave()
            }
            group.enter()
            self.subtasksService.addSubtask(s8t4, to: t4) {
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
}

final class EnMocksConfigurator {
    
    let listsService = ServicesAssembly.shared.listsService
    let tasksService = ServicesAssembly.shared.tasksService
    let subtasksService = ServicesAssembly.shared.subtasksService
    let tagsService = ServicesAssembly.shared.tagsService
    
    func configure(completion: @escaping () -> Void) {
        // Lists
        
        let l1 = List(id: "l1", title: "My project", icon: .job, creationDate: Date())
        l1.isFavorite = true
        let l2 = List(id: "l2", title: "Books, movies, music, games", icon: .games, creationDate: Date())
        let l3 = List(id: "l3", title: "Training", icon: .group, creationDate: Date())
        l3.isFavorite = true
        let l4 = List(id: "l4", title: "Home", icon: .home, creationDate: Date())
        let l5 = List(id: "l5", title: "Goals for the year", icon: .idea, creationDate: Date())
        
        // Tags
        let tag1 = Tag(id: "tag1", title: "Health", color: AppTheme.current.tagColors[5])
        let tag2 = Tag(id: "tag2", title: "Important", color: AppTheme.current.tagColors[0])
        
        // Tasks
        
        let t1 = Task(id: "t1", kind: .single, title: "Watch the latest Star Wars episode", isImportant: true, notification: .doNotNotify, notificationDate: nil, notificationTime: nil, note: "", link: "", repeating: .init(type: .never), repeatEndingDate: nil, dueDate: nil, location: nil, address: nil, shouldNotifyAtLocation: false, attachments: [], isDone: false, inProgress: false, creationDate: Date(), doneDates: [])
        
        let t2 = Task(id: "t2", kind: .single, title: "Read \"The Catcher in the Rye\"", isImportant: false, notification: .doNotNotify, notificationDate: nil, notificationTime: nil, note: "", link: "", repeating: .init(type: .never), repeatEndingDate: nil, dueDate: Date() + 1.asDays, location: nil, address: nil, shouldNotifyAtLocation: false, attachments: [], isDone: false, inProgress: false, creationDate: Date(), doneDates: [])
        
        let t3 = Task(id: "t3", kind: .regular, title: "Work on the project", isImportant: false, notification: .justInTime, notificationDate: nil, notificationTime: nil, note: "", link: "", repeating: .init(type: .every(.day)), repeatEndingDate: nil, dueDate: Date(), location: nil, address: nil, shouldNotifyAtLocation: false, attachments: [], isDone: false, inProgress: false, creationDate: Date(), doneDates: [])
        
        let t4 = Task(id: "t4", kind: .single, title: "Buy products", isImportant: true, notification: .doNotNotify, notificationDate: nil, notificationTime: nil, note: "", link: "", repeating: .init(type: .never), repeatEndingDate: nil, dueDate: Date() + 2.asHours, location: nil, address: nil, shouldNotifyAtLocation: false, attachments: [], isDone: false, inProgress: false, creationDate: Date(), doneDates: [])
        t4.tags = [tag2]
        let s1t4 = Subtask(id: "s1t4", title: "Bread", isDone: true, sortPosition: 0, creationDate: Date())
        let s2t4 = Subtask(id: "s2t4", title: "Milk", isDone: true, sortPosition: 1, creationDate: Date())
        let s3t4 = Subtask(id: "s3t4", title: "Eggs", isDone: true, sortPosition: 2, creationDate: Date())
        let s4t4 = Subtask(id: "s4t4", title: "Chocolate", isDone: true, sortPosition: 3, creationDate: Date())
        let s5t4 = Subtask(id: "s5t4", title: "Potatoes 5kg", isDone: false, sortPosition: 4, creationDate: Date())
        let s6t4 = Subtask(id: "s6t4", title: "Onion", isDone: false, sortPosition: 5, creationDate: Date())
        let s7t4 = Subtask(id: "s7t4", title: "Meat 1kg", isDone: false, sortPosition: 6, creationDate: Date())
        let s8t4 = Subtask(id: "s8t4", title: "Sour cream", isDone: false, sortPosition: 7, creationDate: Date())
        
        let t5 = Task(id: "t5", kind: .single, title: "Therapist", isImportant: true, notification: .till1day, notificationDate: nil, notificationTime: (19, 40), note: "", link: "", repeating: .init(type: .never), repeatEndingDate: nil, dueDate: Date() + 2.asDays, location: nil, address: nil, shouldNotifyAtLocation: false, attachments: [], isDone: false, inProgress: false, creationDate: Date(), doneDates: [])
        t5.tags = [tag1]
        
        let t6 = Task(id: "t6", kind: .single, title: "Lesson with a trainer", isImportant: false, notification: .till1hour, notificationDate: nil, notificationTime: nil, note: "", link: "", repeating: .init(type: .never), repeatEndingDate: nil, dueDate: Date() + 4.asDays - 2.asHours, location: nil, address: nil, shouldNotifyAtLocation: false, attachments: [], isDone: false, inProgress: false, creationDate: Date(), doneDates: [])
        
        let t7 = Task(id: "t7", kind: .single, title: "Buy sports nutrition", isImportant: false, notification: .doNotNotify, notificationDate: nil, notificationTime: nil, note: "", link: "", repeating: .init(type: .never), repeatEndingDate: nil, dueDate: Date() - 4.asDays, location: nil, address: nil, shouldNotifyAtLocation: false, attachments: [], isDone: true, inProgress: false, creationDate: Date(), doneDates: [])
        t7.tags = [tag2]
        
        let t8 = Task(id: "t8", kind: .single, title: "Pick up a hammer from a neighbor", isImportant: true, notification: .doNotNotify, notificationDate: nil, notificationTime: nil, note: "", link: "", repeating: .init(type: .never), repeatEndingDate: nil, dueDate: nil, location: nil, address: nil, shouldNotifyAtLocation: false, attachments: [], isDone: false, inProgress: false, creationDate: Date(), doneDates: [])
        
        let t9 = Task(id: "t9", kind: .single, title: "Fix the car", isImportant: true, notification: .doNotNotify, notificationDate: nil, notificationTime: nil, note: "", link: "", repeating: .init(type: .never), repeatEndingDate: nil, dueDate: nil, location: nil, address: nil, shouldNotifyAtLocation: false, attachments: [], isDone: false, inProgress: false, creationDate: Date(), doneDates: [])
        
        let t10 = Task(id: "t10", kind: .single, title: "Buy a new car", isImportant: false, notification: .doNotNotify, notificationDate: nil, notificationTime: nil, note: "", link: "", repeating: .init(type: .never), repeatEndingDate: nil, dueDate: nil, location: nil, address: nil, shouldNotifyAtLocation: false, attachments: [], isDone: false, inProgress: false, creationDate: Date(), doneDates: [])
        
        let t11 = Task(id: "t11", kind: .single, title: "Download Star Craft", isImportant: false, notification: .doNotNotify, notificationDate: nil, notificationTime: nil, note: "", link: "", repeating: .init(type: .never), repeatEndingDate: nil, dueDate: nil, location: nil, address: nil, shouldNotifyAtLocation: false, attachments: [], isDone: true, inProgress: false, creationDate: Date(), doneDates: [])
        
        let t12 = Task(id: "t12", kind: .single, title: "Listen Metallica - Nothing else matters", isImportant: false, notification: .doNotNotify, notificationDate: nil, notificationTime: nil, note: "", link: "", repeating: .init(type: .never), repeatEndingDate: nil, dueDate: nil, location: nil, address: nil, shouldNotifyAtLocation: false, attachments: [], isDone: false, inProgress: false, creationDate: Date(), doneDates: [])
        
        // Save
        
        let group = DispatchGroup()
        
        DispatchQueue.global().async {
            
            // Tags
            
            group.enter()
            self.tagsService.createOrUpdateTag(tag1) {
                group.leave()
            }
            group.enter()
            self.tagsService.createOrUpdateTag(tag2) {
                group.leave()
            }
            
            group.wait()
            
            // Lists
            
            group.enter()
            self.listsService.createOrUpdateList(l1, tasks: []) { _ in
                group.leave()
            }
            group.enter()
            self.listsService.createOrUpdateList(l2, tasks: []) { _ in
                group.leave()
            }
            group.enter()
            self.listsService.createOrUpdateList(l3, tasks: []) { _ in
                group.leave()
            }
            group.enter()
            self.listsService.createOrUpdateList(l4, tasks: []) { _ in
                group.leave()
            }
            group.enter()
            self.listsService.createOrUpdateList(l5, tasks: []) { _ in
                group.leave()
            }
            
            group.wait()
            
            // Tasks
            
            group.enter()
            self.tasksService.addTask(t1, listID: l2.id) { _ in
                group.leave()
            }
            group.enter()
            self.tasksService.addTask(t2, listID: l2.id) { _ in
                group.leave()
            }
            group.enter()
            self.tasksService.addTask(t3, listID: l1.id) { _ in
                group.leave()
            }
            group.enter()
            self.tasksService.addTask(t4, listID: SmartListType.all.id) { _ in
                group.leave()
            }
            group.enter()
            self.tasksService.addTask(t5, listID: SmartListType.all.id) { _ in
                group.leave()
            }
            group.enter()
            self.tasksService.addTask(t6, listID: l3.id) { _ in
                group.leave()
            }
            group.enter()
            self.tasksService.addTask(t7, listID: l3.id) { _ in
                group.leave()
            }
            group.enter()
            self.tasksService.addTask(t8, listID: l4.id) { _ in
                group.leave()
            }
            group.enter()
            self.tasksService.addTask(t9, listID: l4.id) { _ in
                group.leave()
            }
            group.enter()
            self.tasksService.addTask(t10, listID: l5.id) { _ in
                group.leave()
            }
            group.enter()
            self.tasksService.addTask(t11, listID: l2.id) { _ in
                group.leave()
            }
            group.enter()
            self.tasksService.addTask(t12, listID: l2.id) { _ in
                group.leave()
            }
            
            group.wait()
            
            // Subtasks
            
            group.enter()
            self.subtasksService.addSubtask(s1t4, to: t4) {
                group.leave()
            }
            group.enter()
            self.subtasksService.addSubtask(s2t4, to: t4) {
                group.leave()
            }
            group.enter()
            self.subtasksService.addSubtask(s3t4, to: t4) {
                group.leave()
            }
            group.enter()
            self.subtasksService.addSubtask(s4t4, to: t4) {
                group.leave()
            }
            group.enter()
            self.subtasksService.addSubtask(s5t4, to: t4) {
                group.leave()
            }
            group.enter()
            self.subtasksService.addSubtask(s6t4, to: t4) {
                group.leave()
            }
            group.enter()
            self.subtasksService.addSubtask(s7t4, to: t4) {
                group.leave()
            }
            group.enter()
            self.subtasksService.addSubtask(s8t4, to: t4) {
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
    
}
