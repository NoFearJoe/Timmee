//
//  ListEntity+Mapping.swift
//  Timmee
//
//  Created by Ilya Kharabet on 25.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foundation.NSDate

public extension ListEntity {

    func map(from list: List) {
        id = list.id
        title = list.title
        note = list.note
        iconID = Int16(list.icon.rawValue)
        sortPosition = Int16(list.sortPosition)
        isFavorite = list.isFavorite
        creationDate = list.creationDate
    }

}
