//
//  String+Trimmed.swift
//  Timmee
//
//  Created by Ilya Kharabet on 17.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

public extension String {

    public var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

}

public extension Optional where Wrapped == String {

    public var orEmpty: Wrapped {
        return self ?? ""
    }

}
