//
//  Foto.Photo+filename.swift
//  Timmee
//
//  Created by i.kharabet on 19.12.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import class Foto.Photo

extension Photo {
    
    public var name: String {
        return filename ?? creationDate?.asDateTimeString ?? ""
    }
    
}
