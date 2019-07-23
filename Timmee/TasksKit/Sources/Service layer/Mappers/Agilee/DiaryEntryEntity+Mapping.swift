//
//  DiaryEntryEntity+Mapping.swift
//  TasksKit
//
//  Created by i.kharabet on 23/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

public extension DiaryEntryEntity {
    
    func map(from entity: DiaryEntry) {
        id = entity.id
        text = entity.text
        date = entity.date
        attachment = entity.attachment.string
    }
    
}

extension DiaryEntryEntity: IdentifiableEntity, ModifiableEntity, SyncableEntity {}
