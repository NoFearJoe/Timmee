//
//  Array+Item.swift
//  SwiftWorkset
//
//  Created by Ilya Kharabet on 03.02.17.
//  Copyright © 2017 APPLIFTO. All rights reserved.
//

import func Foundation.arc4random_uniform

public extension Array {
    
    /**
     
     Возвращает элемент массива по индексу. Если индекс находится за пределами массива, то вернет nil.
     
     - Parameter index: Индекс массива
     
     - Returns: Объект или nil
     
     */
    public func item(at index: Int) -> Element? {
        return 0..<count ~= index ? self[index] : nil
    }
    
    /**
     
     Возвращает случайный элемент массива. Если массив пустой, то вернет nil.
     
     - Returns: Объект или nil
     
     */
    public func randomItem() -> Element? {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return item(at: index)
    }

}
