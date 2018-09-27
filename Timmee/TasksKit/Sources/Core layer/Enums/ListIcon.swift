//
//  ListIcon.swift
//  Timmee
//
//  Created by Ilya Kharabet on 26.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import Workset
import class UIKit.UIFont
import class UIKit.UIImage
import class UIKit.UIScreen
import struct Foundation.Date
import class Foundation.NSString
import struct CoreGraphics.CGRect
import class UIKit.NSMutableParagraphStyle
import func Foundation.arc4random_uniform
import struct Foundation.NSAttributedStringKey
import func UIKit.UIGraphicsEndImageContext
import func UIKit.UIGraphicsGetCurrentContext
import func UIKit.UIGraphicsBeginImageContextWithOptions
import func UIKit.UIGraphicsGetImageFromCurrentImageContext

public enum ListIcon: Int {
    case `default` = 0
    case job = 1
    case shopping = 2
    case lock = 3
    case group = 4
    case home = 5
    case eat = 6
    case games = 7
    case idea = 8
    case money = 9
    case star = 10
    case chat = 11
    case art = 12
    case call = 13
    case mail = 14
    
    case allTasks
    case today
    case tomorrow
    case week
    case inProgress
    case overdue
    case important
    
    public static let all: [ListIcon] = [.default, .job, .shopping, .lock, .group, .home, .eat, .games, .idea, .money, .star, .chat, .art, .call, .mail]
    
    public init(id: Int) {
        self.init(rawValue: id)!
    }
}

public extension ListIcon {

    public var image: UIImage {
        switch self {
        case .default: return #imageLiteral(resourceName: "defaultListIcon")
        case .job: return #imageLiteral(resourceName: "jobListIcon")
        case .shopping: return #imageLiteral(resourceName: "shoppingListIcon")
        case .lock: return #imageLiteral(resourceName: "lockListIcon")
        case .group: return #imageLiteral(resourceName: "groupListIcon")
        case .home: return #imageLiteral(resourceName: "homeListIcon")
        case .eat: return #imageLiteral(resourceName: "eatListIcon")
        case .games: return #imageLiteral(resourceName: "gamesListIcon")
        case .idea: return #imageLiteral(resourceName: "ideaListIcon")
        case .money: return #imageLiteral(resourceName: "moneyListIcon")
        case .star: return #imageLiteral(resourceName: "starListIcon")
        case .chat: return #imageLiteral(resourceName: "chatListIcon")
        case .art: return #imageLiteral(resourceName: "artListIcon")
        case .call: return #imageLiteral(resourceName: "callListIcon")
        case .mail: return #imageLiteral(resourceName: "mailListIcon")
            
        case .allTasks: return #imageLiteral(resourceName: "defaultListIcon")
        case .today: return ListIcon.drawDayIcon(forDay: Date().dayOfMonth)
        case .tomorrow: return ListIcon.drawDayIcon(forDay: Date().nextDay.dayOfMonth)
        case .week: return #imageLiteral(resourceName: "weekListIcon")
        case .inProgress: return #imageLiteral(resourceName: "mailListIcon")
        case .overdue: return #imageLiteral(resourceName: "overdue")
        case .important: return #imageLiteral(resourceName: "importantListIcon")
        }
    }

}

public extension ListIcon {

    public static var randomIcon: ListIcon {
        let randomRawValue = Int(arc4random_uniform(13))
        return ListIcon(rawValue: randomRawValue) ?? .default
    }

}

private extension ListIcon {

    static func drawDayIcon(forDay day: Int) -> UIImage {
        let sourceImage: UIImage = #imageLiteral(resourceName: "calendarListIcon")
        
        UIGraphicsBeginImageContextWithOptions(sourceImage.size, false, UIScreen.main.scale)
        
        sourceImage.draw(in: CGRect(origin: .zero, size: sourceImage.size))
        
        let textRect = CGRect(x: 0, y: 6, width: sourceImage.size.width, height: sourceImage.size.height - 6)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .medium),
            .paragraphStyle: paragraphStyle
        ]
        ("\(day)" as NSString).draw(in: textRect, withAttributes: textAttributes)
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext() ?? sourceImage
        
        UIGraphicsEndImageContext()
        
        return resultImage.withRenderingMode(.alwaysTemplate)
    }

}
