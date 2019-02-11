//
//  PeriodicallySynchronizationRunner.swift
//  Synchronization
//
//  Created by i.kharabet on 25.01.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import Foundation

public protocol PeriodicallySynchronizationRunnerDelegate: AnyObject {
    func willStartSynchronization()
    func didFinishSynchronization()
}

// TODO: Не делать синхронзацию во время создания спринта
public final class PeriodicallySynchronizationRunner {
    
    public static let willStartSynchronizationNotificationName = "willStartSynchronization"
    public static let didFinishSynchronizationNotificationName = "didFinishSynchronization"
    
    public weak var delegate: PeriodicallySynchronizationRunnerDelegate?
    
    private let synchronizationService: SynchronizationService
    private var timer: Timer?
    
    private var isInitialSynchronizationFired = false
    
    public init(synchronizationService: SynchronizationService) {
        self.synchronizationService = synchronizationService
    }
    
    public func run(interval: TimeInterval) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false, block: { [weak self] timer in
            guard let self = self else { return }
            guard self.synchronizationService.synchronizationEnabled else {
                self.run(interval: interval)
                return
            }
            self.notifySynchronizationWillStart()
            self.synchronizationService.sync(completion: { [weak self] success in
                guard let self = self else { return }
                self.notifySynchronizationDidFinish()
                self.run(interval: interval)
            })
        })
        
        if !isInitialSynchronizationFired {
            isInitialSynchronizationFired = true
            timer?.fire()
        }
    }
    
    public func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func notifySynchronizationWillStart() {
        delegate?.willStartSynchronization()
        NotificationCenter.default.post(
            Notification(name:
                Notification.Name(rawValue: PeriodicallySynchronizationRunner.willStartSynchronizationNotificationName)
        ))
    }
    
    private func notifySynchronizationDidFinish() {
        delegate?.didFinishSynchronization()
        NotificationCenter.default.post(
            Notification(name:
                Notification.Name(rawValue: PeriodicallySynchronizationRunner.didFinishSynchronizationNotificationName)
        ))
    }
    
}
