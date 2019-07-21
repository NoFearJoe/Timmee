//
//  AppLinkHandler.swift
//  Agile diary
//
//  Created by Илья Харабет on 21/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import TasksKit

final class AppLinkHandler: SprintInteractorTrait {
    
    var window: UIWindow?
    
    var sprintsService = ServicesAssembly.shared.sprintsService
    
    func handle(url: URL) {
        if url.scheme == "agilee" {
            switch url.host {
            case "configure_water_control":
                guard let waterControlConfigurationNavigationController = UIStoryboard(name: "WaterControl", bundle: nil).instantiateInitialViewController() as? UINavigationController
                    else { return }
                
                guard let currentSprint = getCurrentSprint()
                    else { return }
                
                guard let waterControlConfigurationViewController = waterControlConfigurationNavigationController.viewControllers.first as? WaterControlConfigurationViewController
                    else { return }
                
                waterControlConfigurationViewController.sprint = currentSprint
                
                window?.rootViewController?.present(waterControlConfigurationNavigationController, animated: true, completion: nil)
            default: break
            }
        }
    }
    
    
}
