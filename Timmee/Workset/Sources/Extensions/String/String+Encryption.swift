//
//  String+Encryption.swift
//  Timmee
//
//  Created by Ilya Kharabet on 13.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foundation.NSData

public extension String {
    
    public func sha256() -> String {
        guard let data = self.data(using: .utf8) else { return "" }
        return data.base64EncodedString()
    }

}
