//
//  ListIcon.swift
//  Timmee
//
//  Created by Ilya Kharabet on 26.08.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class UIKit.UIImage
import func Foundation.arc4random_uniform

enum ListIcon: Int {
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
    
    static let all: [ListIcon] = [.default, .job, .shopping, .lock, .group, .home, .eat, .games, .idea, .money, .star, .chat, .art, .call, .mail]
    
    init(id: Int) {
        self.init(rawValue: id)!
    }
}

extension ListIcon {

    var image: UIImage {
        switch self {
        case .default: return UIImage(named: "defaultListIcon")!
        case .job: return UIImage(named: "jobListIcon")!
        case .shopping: return UIImage(named: "shoppingListIcon")!
        case .lock: return UIImage(named: "lockListIcon")!
        case .group: return UIImage(named: "groupListIcon")!
        case .home: return UIImage(named: "homeListIcon")!
        case .eat: return UIImage(named: "eatListIcon")!
        case .games: return UIImage(named: "gamesListIcon")!
        case .idea: return UIImage(named: "ideaListIcon")!
        case .money: return UIImage(named: "moneyListIcon")!
        case .star: return UIImage(named: "starListIcon")!
        case .chat: return UIImage(named: "chatListIcon")!
        case .art: return UIImage(named: "artListIcon")!
        case .call: return UIImage(named: "callListIcon")!
        case .mail: return UIImage(named: "mailListIcon")!
        }
    }

}

extension ListIcon {

    static var randomIcon: ListIcon {
        let randomRawValue = Int(arc4random_uniform(13))
        return ListIcon(rawValue: randomRawValue) ?? .default
    }

}
