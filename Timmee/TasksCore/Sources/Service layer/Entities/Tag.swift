//
//  Tag.swift
//  Timmee
//
//  Created by Ilya Kharabet on 22.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIColor

public final class Tag {
    
    public let id: String
    public var title: String
    public var color: UIColor
    
    public init(entity: TagEntity) {
        id = entity.id ?? ""
        title = entity.title ?? ""
        color = UIColor(rgba: entity.color ?? "")
    }
    
    public init(id: String, title: String, color: UIColor) {
        self.id = id
        self.title = title
        self.color = color
    }
    
}

extension Tag: Equatable {
    
    public static func ==(lhs: Tag, rhs: Tag) -> Bool {
        return lhs.id == rhs.id
    }
    
}
