//
//  String+Trimmed.swift
//  Timmee
//
//  Created by Ilya Kharabet on 17.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

extension String {

    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

}

extension Optional where Wrapped == String {

    var orEmpty: Wrapped {
        return self ?? ""
    }

}
