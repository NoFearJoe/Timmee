//
//  UIImage+one-colored.swift
//  SwiftWorkset
//
//  Created by Ilya Kharabet on 03.05.17.
//  Copyright © 2017 APPLIFTO. All rights reserved.
//

import class UIKit.UIImage
import class UIKit.UIColor
import struct CoreGraphics.CGSize
import struct CoreGraphics.CGRect
import func UIKit.UIGraphicsBeginImageContext
import func UIKit.UIGraphicsGetCurrentContext
import func UIKit.UIGraphicsGetImageFromCurrentImageContext
import func UIKit.UIGraphicsEndImageContext


public extension UIImage {

    /**
     
     Создает одноцветное изображение заданного размера. Чаще нужно для создания изображений для свойств shadowImage, backgroundImage у различных панелей.
     
     - Parameter color: Цвет изображения
     - Parameter size: Размер изображение. По-умолчанию 1х1
     
     - Returns: Изображение или nil в случае неудачи
     
     */
    class func plain(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        
        UIGraphicsBeginImageContext(rect.size)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.setFillColor(color.cgColor)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }

}
