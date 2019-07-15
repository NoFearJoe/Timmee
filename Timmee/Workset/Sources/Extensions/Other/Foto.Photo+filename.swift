//
//  Foto.Photo+filename.swift
//  Timmee
//
//  Created by i.kharabet on 19.12.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foto.Photo

public extension Photo {
    
    var name: String {
        return filename ?? creationDate?.asDateTimeString ?? ""
    }
    
}
