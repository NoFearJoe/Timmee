//
//  SmartListEntity+Mapping.swift
//  Timmee
//
//  Created by i.kharabet on 29.01.18.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import class Foundation.NSDate

extension SmartListEntity {
    
    func map(from list: SmartList) {
        id = list.id
    }
    
}
