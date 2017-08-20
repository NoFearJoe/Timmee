//
//  String+capitalizeFirst.swift
//  Alias
//
//  Created by Ilya Kharabet on 18.01.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
    
    mutating func capitalizedFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    var capitalizedFirst: String {
        return self.capitalizingFirstLetter()
    }
}
