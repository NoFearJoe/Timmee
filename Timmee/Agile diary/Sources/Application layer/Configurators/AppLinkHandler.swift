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
            default: break
            }
        }
    }
    
    
}
