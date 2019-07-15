//
//  String+capitalizeFirst.swift
//  Alias
//
//  Created by Ilya Kharabet on 18.01.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

public extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(prefix(1)).capitalized
        let other = String(dropFirst())
        return first + other
    }
    
    mutating func capitalizedFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    var capitalizedFirst: String {
        return self.capitalizingFirstLetter()
    }
}
