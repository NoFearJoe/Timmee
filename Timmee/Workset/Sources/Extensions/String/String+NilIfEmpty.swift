//
//  String+NilIfEmpty.swift
//  Workset
//
//  Created by Илья Харабет on 07/01/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

public extension String {
    
    var nilIfEmpty: String? {
        return trimmed.isEmpty ? nil : self
    }
    
}

public extension Optional where Wrapped == String {
    
    var nilIfEmpty: String? {
        switch self {
        case let .some(string): return string.nilIfEmpty
        default: return nil
        }
    }
    
}
