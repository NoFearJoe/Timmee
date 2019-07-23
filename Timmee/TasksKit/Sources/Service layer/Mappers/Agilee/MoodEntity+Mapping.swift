//
//  MoodEntity+Mapping.swift
//  TasksKit
//
//  Created by i.kharabet on 19.03.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

public extension MoodEntity {
    
    func map(from mood: Mood) {
        self.mood = mood.kind.rawValue
        self.date = mood.date
    }
    
}

extension MoodEntity: ModifiableEntity, SyncableEntity {}
