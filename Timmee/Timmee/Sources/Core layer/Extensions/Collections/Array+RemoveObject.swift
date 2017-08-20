//
//  Array+RemoveObject.swift
//  SwiftWorkset
//
//  Created by Ilya Kharabet on 03.02.17.
//  Copyright © 2017 APPLIFTO. All rights reserved.
//

public extension Array where Element: Equatable {
    
    /**
     
     Удаляет заданный элемент массива.
     
     - Parameter object: Объект, который необходимо удалить
     
     */
    public mutating func remove(object: Iterator.Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
    
    /**
     
     Удаляет все заданные элементы массива.
     
     - Parameter object: Объект, который необходимо удалить
     
     */
    public mutating func removeAll(object: Iterator.Element) {
        var offset = 0
        
        while let index = index(of: object, offset: offset) {
            self.remove(at: index)
            offset = index
        }
        
    }

    
}
