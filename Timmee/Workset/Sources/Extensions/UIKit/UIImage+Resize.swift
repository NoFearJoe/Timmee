//
//  UIImage+Resize.swift
//  Workset
//
//  Created by Илья Харабет on 21/03/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

public extension UIImage {
    
    func resize(to size: CGSize) -> UIImage {
        var resultImage = self
        
        guard let cgImage = cgImage else { return resultImage }
        
        let width = Int(size.width)
        let height = Int(size.height)
        let bitsPerComponent = cgImage.bitsPerComponent
        let bytesPerRow = cgImage.bytesPerRow
        let colorSpace = cgImage.colorSpace!
        let bitmapInfo = cgImage.bitmapInfo
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else { return resultImage }
        context.interpolationQuality = .high
        let rect = CGRect(origin: CGPoint.zero, size: size)
        context.draw(cgImage, in: rect)
        
        resultImage = context.makeImage().flatMap { UIImage(cgImage: $0) }!
        
        return resultImage
    }
    
}
