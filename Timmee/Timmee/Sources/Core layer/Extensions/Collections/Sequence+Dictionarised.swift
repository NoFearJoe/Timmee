//
//  Sequence+Dictionarised.swift
//  SwiftWorkset
//
//  Created by Igor Lemeshev on 02.02.17.
//  Copyright © 2017 APPLIFTO. All rights reserved.
//

public extension Collection {

    /**
     
     Возвращает коллекцию, преобразованную в словарь. В качестве ключей используются значения, извлекаемые переданным замыканием из элементов самой коллекции.
     
     Пример: создание словаря записей по их идентификаторам.
     
     ```let dictionary = collection.dictionarised { $0.id } // где id - поле элемента коллекции```
     
     - Parameter key: Замыкание, возвращающее ключ словаря из элемента коллекции
     
     - Returns: Словарь
     
     */
    
    public func dictionarised<Key: Hashable>(by key: (Self.Iterator.Element) -> Key) -> [Key: Self.Iterator.Element] {
        var dictionary: [Key: Self.Generator.Element] = [:]
        
        self.forEach {
            dictionary[key($0)] = $0
        }
        
        return dictionary
    }
    
}
