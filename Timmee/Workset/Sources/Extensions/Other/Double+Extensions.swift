//
//  Double+Extensions.swift
//  Workset
//
//  Created by i.kharabet on 21.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

public extension Double {
    
    public func safeDivide(by divisor: Double) -> Double {
        guard divisor != 0 else { return 0 }
        return self / divisor
    }
    
}

public extension CGFloat {
    
    public func safeDivide(by divisor: CGFloat) -> CGFloat {
        guard divisor != 0 else { return 0 }
        return self / divisor
    }
    
}
