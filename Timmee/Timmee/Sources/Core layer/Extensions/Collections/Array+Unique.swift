//
//  Array+Unique.swift
//  SwiftWorkset
//
//  Created by Ilya Kharabet on 03.02.17.
//  Copyright © 2017 APPLIFTO. All rights reserved.
//

public extension Array {
    
    /**
     
     Возвращает массив с уникальными объектами, выбранными в соответствии с переданным условием.
     
     Пример:
     
     ```
     ["a", "b", "a"].unique { $0.0 == $0.1 } --> ["a", "b"]
     ```
     
     - Parameter include: Определяет условие, по которому будут выбраны уникальные элементы
     - Parameter lhs: Первый элемент
     - Parameter rhs: Второй элемент
     
     - Returns: Массив с уникальными элементами
     
     */
    public func unique(include: @escaping (_ lhs: Element, _ rhs: Element) -> Bool) -> [Element] {
        return reduce([]) { (acc, element) in
            return acc.contains(where: { include(element, $0) }) ? acc : acc + [element]
        }
    }
    
}

public extension Array where Element: Equatable {

    /// Возвращает массив с уникальными объектами, полученными в результате обычного сравнения
    public var unique: [Element] {
        var acc: [Element] = []
        
        self.forEach {
            if !acc.contains($0) {
                acc.append($0)
            }
        }
        
        return acc
    }

}

public extension Array where Element: Hashable {

    /// Быстрое получение уникальных значений для Hashable-элементов
    public var uniqueByHash: [Element] {
        return Array(Set(self))
    }

}
