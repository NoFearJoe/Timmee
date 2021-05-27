//
//  PluralStringLocalization.swift
//  Agile diary
//
//  Created by i.kharabet on 01/08/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import Foundation

extension String {
    
    static func localizedAddNHabits(count: Int) -> String {
        if 11...14 ~= count % 100 {
            return "add_many_habits".localized(with: count)
        }
        switch count % 10 {
        case 1: return "add_one_habit".localized(with: count)
        case 2...4: return "add_few_habits".localized(with: count)
        default: return "add_many_habits".localized(with: count)
        }
    }
    
    static func localizedRemoveNHabits(count: Int) -> String {
        if 11...14 ~= count % 100 {
            return "remove_many_habits".localized(with: count)
        }
        switch count % 10 {
        case 1: return "remove_one_habit".localized(with: count)
        case 2...4: return "remove_few_habits".localized(with: count)
        default: return "remove_many_habits".localized(with: count)
        }
    }
    
}
