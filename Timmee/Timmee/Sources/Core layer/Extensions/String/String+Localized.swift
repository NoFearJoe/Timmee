//
//  String+Localized.swift
//  Timmee
//
//  Created by Ilya Kharabet on 05.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import func Foundation.NSLocalizedString

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with number: Int) -> String {
        return String(format: self.localized, number)
    }
}
