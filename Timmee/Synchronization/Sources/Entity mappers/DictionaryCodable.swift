//
//  DictionaryCodable.swift
//  Synchronization
//
//  Created by i.kharabet on 23.01.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

protocol DictionaryEncodable {
    func encode() -> [String: Any]
}

protocol DictionaryDecodable {
    func decode(_ dictionary: [String: Any])
}
