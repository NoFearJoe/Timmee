//
//  Habit+makePropertiesString.swift
//  Agile diary
//
//  Created by Илья Харабет on 30.05.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import TasksKit

extension Habit {
    
    func makePropertiesString(addDueDays: Bool = true) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        
        if let value = value {
            attributedString.append(NSAttributedString(string: value.localized + " ",
                                                         attributes: [.foregroundColor: AppTheme.current.colors.mainElementColor]))
        }
        
        if addDueDays {
            let repeatMask = RepeatMask(type: .on(.custom(Set(dueDays)))).localized
            let repeatMaskString = attributedString.string.isEmpty ? repeatMask.capitalizedFirst : repeatMask.lowercased()
            attributedString.append(NSAttributedString(string: repeatMaskString + " ",
                                                         attributes: [.foregroundColor: AppTheme.current.colors.inactiveElementColor]))
        }
        
        if let dueTime = dueTime {
            attributedString.append(NSAttributedString(string: "at".localized + " ",
                                                         attributes: [.foregroundColor: AppTheme.current.colors.inactiveElementColor]))
            attributedString.append(NSAttributedString(string: dueTime.string + " ",
                                                         attributes: [.foregroundColor: AppTheme.current.colors.mainElementColor]))
        }
        
        if notification != .none {
            attributedString.append(NSAttributedString(string: " "))
            let attachment = NSTextAttachment(
                image: UIImage(imageLiteralResourceName: "alarm_small")
                    .withTintColor(AppTheme.current.colors.incompleteElementColor)
            )
            attachment.bounds = CGRect(x: 0, y: -0.5, width: 10, height: 10)
            let alarm = NSAttributedString(
                attachment: attachment
            )
            attributedString.append(alarm)
            attributedString.append(NSAttributedString(string: " "))
        }
        
        if !description.isEmpty {
            attributedString.append(NSAttributedString(string: " "))
            let attachment = NSTextAttachment(
                image: UIImage(imageLiteralResourceName: "note_small")
                    .withTintColor(AppTheme.current.colors.inactiveElementColor)
            )
            attachment.bounds = CGRect(x: 0, y: -0.5, width: 10, height: 10)
            let alarm = NSAttributedString(
                attachment: attachment
            )
            attributedString.append(alarm)
        }
        
        return attributedString
    }
    
}
