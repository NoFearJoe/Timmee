//
//  AchievementViewModelsMapper.swift
//  Agile diary
//
//  Created by Илья Харабет on 01/06/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import TasksKit

struct AchievementViewModelsMapper {
    
    static func map(achievements: [AchievementEntity]) -> [AchievementViewModel] {
        let groupedAchievements = Dictionary<String, [AchievementEntity]>(
                grouping: achievements,
                by: { $0.name ?? "" }
            )
            .map { ($0.key, $0.value) }
            .sorted(by: { $0.0 < $1.0 })
        
        return groupedAchievements.compactMap {
            guard let achievement = Achievement(rawValue: $0.0) else { return nil }
            
            return AchievementViewModel(
                title: achievement.title,
                subtitle: nil, // TODO
                count: $0.1.count,
                icon: achievement.icon
            )
        }
    }
    
}
