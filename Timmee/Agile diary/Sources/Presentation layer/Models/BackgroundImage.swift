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
        case .bgImage3: return #imageLiteral(resourceName: "bgImage0")
        case .bgImage4: return #imageLiteral(resourceName: "bgImage0")
        case .bgImage5: return #imageLiteral(resourceName: "bgImage0")
        case .bgImage6: return #imageLiteral(resourceName: "bgImage0")
        case .bgImage7: return #imageLiteral(resourceName: "bgImage0")
        case .bgImage8: return #imageLiteral(resourceName: "bgImage0")
        case .bgImage9: return #imageLiteral(resourceName: "bgImage0")
        }
    }
}
