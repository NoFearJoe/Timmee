//
//  CalendarProtocols.swift
//  UIComponents
//
//  Created by i.kharabet on 27/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

protocol CalendarSectionView: AnyObject {
    var onChangeHeight: ((CGFloat) -> Void)? { get set }
    var onChangeSection: ((CalendarSection) -> Void)? { get set }
    func reload()
    func triggerHeightUpdate()
    func setHeightUpdatesSuspended(_ isSuspended: Bool)
}
