//
//  Tracker.swift
//  Workset
//
//  Created by Илья Харабет on 12.05.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import Foundation


public typealias CheckpointClosure = () -> ()


/**
 Tracker condition types
 
 - Once:      Tracker will evaluate checkpiont once after N usages
 - Every:     Tracker will evaluate checkpoint every N usages
 - Quadratic: Tracker will evaluate checkpoint every time when usages count is power of N
 */
public enum TrackerCondition {
    
    /// Tracker will evaluate checkpiont once after N usages
    case once(UInt)
    
    /// Tracker will evaluate checkpoint every N usages
    case every(UInt)
    
    /// Tracker will evaluate checkpoint every power of N
    case quadratic(UInt)
    
}


/// Tracker class instances pool. Use TrackerPool.sharedInstance[KEY] for getting Tracker instance with desird KEY
fileprivate final class TrackerPool {
    
    /// TrackerPool shared instance
    static let sharedInstance = TrackerPool()
    
    
    subscript(key: String) -> Tracker? {
        get {
            return pool[key]
        }
        set {
            pool[key] = newValue
        }
    }
    
    
    var first: Tracker? {
        return Array(pool.values).first
    }
    
    var last: Tracker? {
        return Array(pool.values).last
    }
    
    
    fileprivate var pool = [String: Tracker]()
    
}


public class Tracker {
    
    /// Class identifier
    fileprivate static let identifier: String = NSStringFromClass(Tracker.self)
    
    /// Closure fired when usages count satisfies the condition
    public var checkpoint: CheckpointClosure?
    
    /// Identification key
    fileprivate(set) var key: String!
    fileprivate(set) var condition: TrackerCondition!
    
    /// Usages counter
    fileprivate(set) var usagesCount: UInt {
        get {
            let value = (UserDefaults.standard.object(forKey: Tracker.identifier + key + "usagesCount") ?? 0) as! Int
            return UInt(value)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Tracker.identifier + key + "usagesCount")
        }
    }
    
    /// Return true if tracker enabled
    fileprivate(set) var enabled: Bool {
        get {
            return (UserDefaults.standard.object(forKey: Tracker.identifier + key + "enabled") ?? true) as! Bool
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Tracker.identifier + key + "enabled")
        }
    }
    
    /*
     Register tracker with given key and condition.
     
     - parameter key:       Identification key
     - parameter condition: Condition type
     
     - returns: Instance of Tracker class
     */
    public class func register(with key: String, condition: TrackerCondition) {
        let tracker = Tracker()
        
        tracker.key = key
        tracker.condition = condition
        
        TrackerPool.sharedInstance[key] = tracker
    }
    
    /*
     Obtain tracker for key.
     
     - Parameter key: Identification key
     
     - Returns: Instance of Tracker class
     */
    public class func obtain(for key: String) -> Tracker? {
        return TrackerPool.sharedInstance[key]
    }
    
    
    /**
     Commit usage. Increment usages count by 1 and check if usages count satisfies condition
     */
    public func commit() {
        if enabled {
            if usagesCount < UInt.max {
                usagesCount += 1
            }
        }
        
        if satisfiesCondition(usagesCount: usagesCount, condition: condition) {
            checkpoint?()
        }
        
        setEnabledByCondition(usagesCount, condition: condition)
    }
    
    /**
     Return tracker to initial state (usages count = 0 and enabled = true)
     */
    public func drop() {
        usagesCount = 0
        enabled = true
    }
    
    
    /**
     Set tracker disabled. WARNING: Tracker never been work after evaluating of this function!
     */
    public func disable() {
        enabled = false
    }
    
    /**
     Check if usages count saticfies condition
     
     - parameter count:     Usages count
     - parameter condition: Condition type
     
     - returns: True if satisfies
     */
    fileprivate func satisfiesCondition(usagesCount count: UInt, condition: TrackerCondition) -> Bool {
        switch condition {
        case .once(let targetCount):
            return enabled && usagesCount == targetCount
        case .every(let targetCount):
            return enabled && Double(usagesCount).truncatingRemainder(dividingBy: Double(targetCount)) == 0
        case .quadratic(let targetCount):
            let power = log(Double(usagesCount)) / log(Double(targetCount))
            return enabled && floor(power) == power && power != 0
        }
    }
    
    /**
     Set tracker disabled if needed
     
     - parameter condition: Condition type
     */
    fileprivate func setEnabledByCondition(_ usagesCount: UInt, condition: TrackerCondition) {
        switch condition {
        case .once(_):
            enabled = false
            break
        case .every(_):
            if usagesCount >= UInt.max {
                enabled = false
            }
            break
        case .quadratic(_):
            if usagesCount >= UInt.max {
                enabled = false
            }
            break
        }
    }
    
    
}
