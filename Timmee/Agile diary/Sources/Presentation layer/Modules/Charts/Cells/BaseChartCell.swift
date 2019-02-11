//
//  BaseChartCell.swift
//  Agile diary
//
//  Created by Илья Харабет on 23.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

class BaseChartCell: UICollectionViewCell {
    
    var onShowFullProgress: (() -> Void)?
    
    class var reuseIdentifier: String {
        return String(describing: self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupAppearance()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setupAppearance()
    }
    
    func setupAppearance() {
        layer.masksToBounds = false
        layer.cornerRadius = 12
        configureShadow(radius: 4, opacity: 0.1)
        backgroundColor = AppTheme.current.colors.foregroundColor
    }
    
    func update(sprint: Sprint) {}
    
    class func size(for collectionViewSize: CGSize) -> CGSize { return .zero }
    
}
