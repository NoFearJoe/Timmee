//
//  ListsSectionView.swift
//  Timmee
//
//  Created by Илья Харабет on 04.02.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class ListsSectionView: UICollectionReusableView {
    
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = AppTheme.current.secondaryTintColor
        }
    }
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue?.uppercased() }
    }
    
}
