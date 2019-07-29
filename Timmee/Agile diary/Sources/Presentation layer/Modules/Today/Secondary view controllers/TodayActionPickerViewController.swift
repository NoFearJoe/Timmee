//
//  TodayActionPickerViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 29/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

enum TodayAction {
    case charts, sprints, diary, settings
}

final class TodayActionPickerViewController: UIAlertController {
    
    var onSelectAction: ((TodayAction) -> Void)?
    
    convenience init(sourceView: UIView) {
        self.init(title: nil,
                  message: nil,
                  preferredStyle: UIAlertController.Style.actionSheet)
        
        if UIDevice.current.isIpad {
            popoverPresentationController?.permittedArrowDirections = .up
            popoverPresentationController?.sourceView = sourceView
        }
        
        addActions()
    }
    
    private func addActions() {
        let sprintsAction = UIAlertAction(title: "my_sprints".localized, style: .default) { [unowned self] _ in
            self.onSelectAction?(.sprints)
        }
        
        let chartsAction = UIAlertAction(title: "my_progress".localized, style: .default) { [unowned self] _ in
            self.onSelectAction?(.charts)
        }
        
        let diaryAction = UIAlertAction(title: "diary".localized, style: .default) { [unowned self] _ in
            self.onSelectAction?(.diary)
        }
        
        let settingsAction = UIAlertAction(title: "settings".localized, style: .default) { [unowned self] _ in
            self.onSelectAction?(.settings)
        }
        
        let closeAction = UIAlertAction(title: "close".localized, style: .cancel, handler: nil)
        
        addAction(chartsAction)
        addAction(sprintsAction)
        addAction(diaryAction)
        addAction(settingsAction)
        addAction(closeAction)
    }
    
}
