//
//  Array+IndexOf.swift
//  SwiftWorkset
//
//  Created by Igor Lemeshev on 03.02.17.
//  Copyright © 2017 APPLIFTO. All rights reserved.
//

public extension Array where Element: Equatable {
    
    /**
     
     Ищет индекс элемента в массиве с начальным отступом
     
     - Parameter element: Элемент, индекс которого необходимо найти
     - Parameter offset: Индекс, с которого начинается поиск
     
     - Returns: Индекс либо nil
     
     */
    func index(of element: Element, offset: Int = 0) -> Int? {
        guard 0..<count ~= offset else {
            return nil
        }
        
        return (offset..<count).first { self[$0] == element }
    }
    
}
