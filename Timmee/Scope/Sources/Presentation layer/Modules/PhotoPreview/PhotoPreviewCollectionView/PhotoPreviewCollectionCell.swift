//
//  PhotoPreviewCollectionCell.swift
//  Timmee
//
//  Created by i.kharabet on 21.12.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class PhotoPreviewCollectionCell: UICollectionViewCell {
    
    @IBOutlet private var photoView: UIImageView!
    
    var photo: UIImage? {
        get { return photoView.image }
        set { photoView.image = newValue }
    }
    
}
