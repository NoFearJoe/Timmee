//
//  Environment.swift
//  Agile diary
//
//  Created by i.kharabet on 13.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

struct Environment {
    
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
}
