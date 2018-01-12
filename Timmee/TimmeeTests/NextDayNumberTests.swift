//
//  NextDayNumberTests.swift
//  TimmeeTests
//
//  Created by i.kharabet on 10.01.18.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import XCTest
@testable import Timmee

class NextDayNumberTests: XCTestCase {
    
    private func task(dueDate: Date, repeatingMask: RepeatMask) -> Task {
        return Task(id: "test",
                    title: "test",
                    isImportant: false,
                    notification: .justInTime,
                    note: "testtest",
                    repeating: repeatingMask,
                    repeatEndingDate: nil,
                    dueDate: dueDate,
                    location: nil,
                    address: nil,
                    shouldNotifyAtLocation: false,
                    attachments: [],
                    isDone: false,
                    inProgress: false,
                    creationDate: Date())
    }
    
    func testRepeatEveryDay() {
        let task = self.task(dueDate: Date(), repeatingMask: RepeatMask(type: .every(.day)))
        guard let nextDueDate = task.nextDueDate else { return }
        
        XCTAssert(nextDueDate.dayOfMonth == task.dueDate!.nextDay.dayOfMonth)
    }
    
    func testRepeatEveryWeek() {
        let task = self.task(dueDate: Date(), repeatingMask: RepeatMask(type: .every(.week)))
        guard let nextDueDate = task.nextDueDate else { return }
        
        XCTAssert(nextDueDate.weekOfYear == (task.dueDate! + 1.asWeeks).weekOfYear)
    }
    
    func testRepeatEveryMonth() {
        let task = self.task(dueDate: Date(), repeatingMask: RepeatMask(type: .every(.month)))
        guard let nextDueDate = task.nextDueDate else { return }
        
        XCTAssert(nextDueDate.month == (task.dueDate! + 1.asMonths).month)
    }
    
    func testRepeatEveryYear() {
        let task = self.task(dueDate: Date(), repeatingMask: RepeatMask(type: .every(.year)))
        guard let nextDueDate = task.nextDueDate else { return }
        
        XCTAssert(nextDueDate.year == (task.dueDate! + 1.asYears).year)
    }
    
    
    func testRepeatEvery2Days() {
        let task = self.task(dueDate: Date(), repeatingMask: RepeatMask(type: .every(.day), value: 2))
        guard let nextDueDate = task.nextDueDate else { return }
        
        XCTAssert(nextDueDate.dayOfMonth == task.dueDate!.nextDay.nextDay.dayOfMonth)
    }
    
    
    func testRepeatOnEveryDay() {
        let task = self.task(dueDate: Date(), repeatingMask: RepeatMask(type: .on(.init(string: "mon,tue,wed,thu,fri,sun,sat"))))
        guard let nextDueDate = task.nextDueDate else { return }
        
        XCTAssert(nextDueDate.dayOfMonth == task.dueDate!.nextDay.dayOfMonth)
    }
    
    
    func testRepeatOnEveryDayFromPast() {
        let task = self.task(dueDate: Date() - 5.asDays, repeatingMask: RepeatMask(type: .every(.day)))
        guard let nextDueDate = task.nextDueDate else { return }
        
        XCTAssert(nextDueDate.dayOfMonth == Date().nextDay.dayOfMonth)
    }
    
}
