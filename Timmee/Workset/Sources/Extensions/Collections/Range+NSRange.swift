//
//  Range+NSRange.swift
//  Workset
//
//  Created by i.kharabet on 28.09.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import struct Foundation.NSRange

extension Range where Bound == String.Index {
    public var nsRange:NSRange {
        return NSRange(location: self.lowerBound.encodedOffset,
                       length: self.upperBound.encodedOffset -
                        self.lowerBound.encodedOffset)
    }
}
