//
//  DiaryEntry.swift
//  TasksKit
//
//  Created by i.kharabet on 23/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import struct Foundation.Date

public class DiaryEntry: Copyable {
    public var id: String
    public var text: String
    public var date: Date
    public var attachment: Attachment
    
    public init(entity: DiaryEntryEntity) {
        self.id = entity.id ?? ""
        self.text = entity.text ?? ""
        self.date = entity.date ?? Date()
        self.attachment = entity.attachment.map { Attachment(string: $0) } ?? Attachment.none
    }
    
    public init(id: String,
                text: String,
                date: Date,
                attachment: Attachment) {
        self.id = id
        self.text = text
        self.date = date
        self.attachment = attachment
    }
    
    public var copy: DiaryEntry {
        return DiaryEntry(id: id,
                          text: text,
                          date: date,
                          attachment: attachment)
    }
}

public extension DiaryEntry {
    
    enum Attachment {
        case none
        case habit(id: String)
        case goal(id: String)
        case sprint(id: String)
        
        init(string: String) {
            switch string {
            case "none":
                self = .none
            default:
                let components = string.split(separator: "_").map { String($0) }
                guard components.count == 2 else {
                    self = .none
                    return
                }
                switch components[0] {
                case "habit":
                    self = .habit(id: components[1])
                case "goal":
                    self = .goal(id: components[1])
                case "sprint":
                    self = .sprint(id: components[1])
                default:
                    self = .none
                }
            }
        }
        
        var string: String {
            switch self {
            case .none:
                return "none"
            case let .habit(id):
                return "habit_" + id
            case let .goal(id):
                return "goal_" + id
            case let .sprint(id):
                return "sprint_" + id
            }
        }
        
        var filteringPredicate: NSPredicate {
            switch self {
            case .none:
                return NSPredicate(format: "attachment == %@", "none")
            case let .habit(id):
                return NSPredicate(format: "attachment CONTAINS[cd] %@ AND attachment CONTAINS[cd] %@", "habit", id)
            case let .goal(id):
                return NSPredicate(format: "attachment CONTAINS[cd] %@ AND attachment CONTAINS[cd] %@", "goal", id)
            case let .sprint(id):
                return NSPredicate(format: "attachment CONTAINS[cd] %@ AND attachment CONTAINS[cd] %@", "sprint", id)
            }
        }
    }
    
}

extension DiaryEntry: Equatable {
    
    public static func == (lhs: DiaryEntry, rhs: DiaryEntry) -> Bool {
        return lhs.id == rhs.id
    }
    
}

extension DiaryEntry: CustomEquatable {
    
    public func isEqual(to item: DiaryEntry) -> Bool {
        return id == item.id
            && text == item.text
            && date == item.date
            && attachment == item.attachment
    }
    
}

extension DiaryEntry.Attachment: Equatable {
    
    public static func == (lhs: DiaryEntry.Attachment, rhs: DiaryEntry.Attachment) -> Bool {
        return lhs.string == rhs.string
    }
    
}
