//
//  DispatchQueue+safeAsync.swift
//  Workset
//
//  Created by i.kharabet on 16/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import class Foundation.DispatchQueue

public extension DispatchQueue {
    func safeAsync(_ block: @escaping () -> Void) {
        if self === DispatchQueue.main, Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async {
                block()
            }
        }
    }
}
