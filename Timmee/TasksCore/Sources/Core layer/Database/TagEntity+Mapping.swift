//
//  TagEntity+Mapping.swift
//  Timmee
//
//  Created by Ilya Kharabet on 22.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import Workset

public extension TagEntity {
    
    public func map(from tag: Tag) {
        id = tag.id
        title = tag.title
        color = tag.color.hexString()
    }
    
}
