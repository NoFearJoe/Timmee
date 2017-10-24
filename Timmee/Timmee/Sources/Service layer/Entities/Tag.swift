//
//  Tag.swift
//  Timmee
//
//  Created by Ilya Kharabet on 22.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIColor

final class Tag {
    
    let id: String
    var title: String
    var color: UIColor
    
    init(entity: TagEntity) {
        id = entity.id ?? ""
        title = entity.title ?? ""
        color = UIColor(rgba: entity.color ?? "")
    }
    
    init(id: String, title: String, color: UIColor) {
        self.id = id
        self.title = title
        self.color = color
    }
    
}

extension Tag: Equatable {
    
    static func ==(lhs: Tag, rhs: Tag) -> Bool {
        return lhs.id == rhs.id
    }
    
}
