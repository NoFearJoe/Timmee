//
//  NumberPadItem.swift
//  Test
//
//  Created by i.kharabet on 13.10.17.
//  Copyright © 2017 i.kharabet. All rights reserved.
//

import class UIKit.UIImage
import class UIKit.UIDevice
import class LocalAuthentication.LAContext

struct NumberPadItem {
    
    enum Style {
        case number(value: Int)
        case symbol(string: String)
        case icon(image: UIImage)
    }
    
    enum Kind {
        case number(value: Int)
        case clear
        case biometrics
        case cancel
    }
    
    /// То, что нужно отобразить
    let style: Style
    
    /// То, что нужно обработать
    let kind: Kind
    
    init(kind: Kind) {
        self.kind = kind
        
        switch kind {
        case .number(let value): style = .number(value: value)
        case .clear: style = .icon(image: #imageLiteral(resourceName: "clear_arrow"))
        case .biometrics:
            switch UIDevice.current.biometricsType {
            case .none: style = .icon(image: UIImage())
            case .touchID: style = .icon(image: #imageLiteral(resourceName: "touchIDSmall"))
            case .faceID: style = .icon(image: #imageLiteral(resourceName: "faceIDSmall"))
            }
        case .cancel: style = .symbol(string: "cancel".localized.lowercased())
        }
    }
    
    init(kind: Kind, style: Style) {
        self.kind = kind
        self.style = style
    }
    
}
