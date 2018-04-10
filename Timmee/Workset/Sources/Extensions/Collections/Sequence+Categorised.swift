//
//  Sequence+Categorised.swift
//  SwiftWorkset
//
//  Created by Ilya Kharabet on 02.02.17.
//  Copyright © 2017 APPLIFTO. All rights reserved.
//

public extension Sequence {

    /**
     Группирует элементы последовательности по заданному ключу.
     Пример: есть массив собак, надо сгруппировать их по породе:
     ```
     let result = dogs.categorised(by: { $0.kind })
     ```
     В результате получим: ["Доберман": [...], "Овчарка": [...]]
     
     - Parameter key: Функция, определяющая ключ для элемента.
     
     - Returns: Словарь сгруппированный по ключу.
    */
    public func categorised<Key: Hashable>(by key: @escaping (Iterator.Element) -> Key) -> [Key: [Iterator.Element]] {
        var accumulated: [Key: [Iterator.Element]] = [:]
        self.forEach { element in
            let key = key(element)
            if case .none = accumulated[key]?.append(element) {
                accumulated[key] = [element]
            }
        }
        return accumulated
    }

}
