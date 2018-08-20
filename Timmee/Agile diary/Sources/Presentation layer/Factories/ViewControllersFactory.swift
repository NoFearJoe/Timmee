//
//  ViewControllersFactory.swift
//  Agile diary
//
//  Created by i.kharabet on 13.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class ViewControllersFactory {
    
    static var educationRoot: EducationPageViewController {
        return UIStoryboard(name: "Education", bundle: nil).instantiateInitialViewController() as! EducationPageViewController
    }
    
    static var education: EducationViewController {
        return UIStoryboard(name: "Education", bundle: nil).instantiateViewController(withIdentifier: "Education") as! EducationViewController
    }
    
    static var sprintCreation: SprintCreationViewController {
        return UIStoryboard(name: "SprintCreation", bundle: nil).instantiateInitialViewController() as! SprintCreationViewController
    }
    
    static var notificationTimePicker: NotificationTimePicker {
        return UIStoryboard(name: "SprintCreation", bundle: nil).instantiateViewController(withIdentifier: "NotificationTimePicker") as! NotificationTimePicker
    }
    
}
