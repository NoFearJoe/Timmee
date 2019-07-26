//
//  DiaryEntryAttachmentTypePickerViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 26/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class DiaryEntryAttachmentTypePickerViewController: UIAlertController {
    
    convenience init(sourceView: UIView) {
        self.init(title: "diary_entry_attachment_type_picker_title".localized,
                  message: nil,
                  preferredStyle: UIAlertController.Style.actionSheet)
        
        if UIDevice.current.isIpad {
            popoverPresentationController?.permittedArrowDirections = .down
            popoverPresentationController?.sourceView = sourceView
        }
        
        addActions()
    }
    
    private func addActions() {
        let sprintAction = UIAlertAction(title: "diary_attachment_sprint".localized, style: .default) { _ in
            
        }
        
        let habitAction = UIAlertAction(title: "diary_attachment_habit".localized, style: .default) { _ in
            
        }
        
        let goalAction = UIAlertAction(title: "diary_attachment_goal".localized, style: .default) { _ in
            
        }
        
        let closeAction = UIAlertAction(title: "close".localized, style: .cancel, handler: nil)
        
        addAction(habitAction)
        addAction(goalAction)
        addAction(sprintAction)
        addAction(closeAction)
    }
    
}
