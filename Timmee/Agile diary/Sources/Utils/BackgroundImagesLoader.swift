//
//  BackgroundImagesLoader.swift
//  Agile diary
//
//  Created by Илья Харабет on 16/02/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import Foundation

final class BackgroundImagesLoader {
    
    static let shared = BackgroundImagesLoader()
    
    var onLoad: (() -> Void)?
    
    private let request = NSBundleResourceRequest(tags: ["BackgroundImages"])
    
    func load() {
        request.conditionallyBeginAccessingResources { [unowned self] isAvailable in
            guard !isAvailable else { return }
            self.request.beginAccessingResources(completionHandler: { [unowned self] error in
                self.onLoad?()
            })
        }
    }
    
}
