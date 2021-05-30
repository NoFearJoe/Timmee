//
//  PickDayButton.swift
//  Agile diary
//
//  Created by i.kharabet on 18/10/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class PickDayButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    private func setup() {
        layer.cornerRadius = 8
        clipsToBounds = true
        
        contentEdgeInsets.top = 2
        setImage(UIImage(named: "pickDayIcon"), for: .normal)
        setBackgroundImage(.plain(color: AppTheme.current.colors.decorationElementColor), for: .normal)
        tintColor = AppTheme.current.colors.activeElementColor
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let touchArea = bounds.insetBy(dx: -12, dy: -12)
        return touchArea.contains(point)
    }
    
}
