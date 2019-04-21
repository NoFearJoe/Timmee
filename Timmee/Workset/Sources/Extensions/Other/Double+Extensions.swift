//
//  Double+Extensions.swift
//  Workset
//
//  Created by i.kharabet on 21.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

public extension Double {
    
    func safeDivide(by divisor: Double) -> Double {
        guard divisor != 0 else { return 0 }
        return self / divisor
    }
    
}

public extension CGFloat {
    
    func safeDivide(by divisor: CGFloat) -> CGFloat {
        guard divisor != 0 else { return 0 }
        return self / divisor
    }
    
}

public extension Double {
    
    func rounded(precision: Int) -> Double {
        let precision: Double = Double(10 * precision)
        return Foundation.round(precision * self) / precision
    }
    
}
