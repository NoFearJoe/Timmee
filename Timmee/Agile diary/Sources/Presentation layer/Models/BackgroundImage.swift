//
//  BackgroundImage.swift
//  Agile diary
//
//  Created by i.kharabet on 20.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

enum BackgroundImage: String {
    case noImage
    case bgImage0
    case bgImage1
    case bgImage2
    case bgImage3
    case bgImage4
    case bgImage5
    case bgImage6
    case bgImage7
    case bgImage8
    case bgImage9
    
    static let all: [BackgroundImage] = [bgImage0, bgImage1, bgImage2, bgImage3, bgImage4, bgImage5, bgImage6, bgImage7, bgImage8, bgImage9]
    
    static var current: BackgroundImage {
        return BackgroundImage(rawValue: UserProperty.backgroundImage.string()) ?? .noImage
    }
    
    var image: UIImage? {
        switch self {
        case .noImage: return nil
        case .bgImage0: return UIImage(named: "bgImage0")!
        case .bgImage1: return UIImage(named: "bgImage1")!
        case .bgImage2: return UIImage(named: "bgImage2")!
        case .bgImage3: return UIImage(named: "bgImage3")!
        case .bgImage4: return UIImage(named: "bgImage4")!
        case .bgImage5: return UIImage(named: "bgImage5")!
        case .bgImage6: return UIImage(named: "bgImage6")!
        case .bgImage7: return UIImage(named: "bgImage7")!
        case .bgImage8: return UIImage(named: "bgImage8")!
        case .bgImage9: return UIImage(named: "bgImage9")!
        }
    }
    
    var previewImage: UIImage? {
        switch self {
        case .noImage: return nil
        case .bgImage0: return UIImage(named: "bgImage0preview")!
        case .bgImage1: return UIImage(named: "bgImage1preview")!
        case .bgImage2: return UIImage(named: "bgImage2preview")!
        case .bgImage3: return UIImage(named: "bgImage3preview")!
        case .bgImage4: return UIImage(named: "bgImage4preview")!
        case .bgImage5: return UIImage(named: "bgImage5preview")!
        case .bgImage6: return UIImage(named: "bgImage6preview")!
        case .bgImage7: return UIImage(named: "bgImage7preview")!
        case .bgImage8: return UIImage(named: "bgImage8preview")!
        case .bgImage9: return UIImage(named: "bgImage9preview")!
        }
    }
    
}
