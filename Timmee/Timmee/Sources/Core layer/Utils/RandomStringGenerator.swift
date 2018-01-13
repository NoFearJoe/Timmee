//
//  RandomStringGenerator.swift
//  Timmee
//
//  Created by Ilya Kharabet on 26.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import func Foundation.arc4random_uniform

final class RandomStringGenerator {

    fileprivate static let characters = Array("qwertyuiopasdfghjklzxcvbnm1234567890")
    
    static func randomString(length: Int) -> String {
        return (0..<length).flatMap { _ in
            let randomIndex = Int(arc4random_uniform(UInt32(characters.count)))
            guard let char = characters.item(at: randomIndex) else { return nil }
            return String(char)
        }.joined()
    }

}
