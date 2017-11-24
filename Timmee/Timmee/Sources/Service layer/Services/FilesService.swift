//
//  FilesService.swift
//  Timmee
//
//  Created by i.kharabet on 24.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import Foundation

final class FilesService {
    
    fileprivate struct Paths {
        fileprivate static let documents = try? FileManager.default.url(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
    }
    
}
