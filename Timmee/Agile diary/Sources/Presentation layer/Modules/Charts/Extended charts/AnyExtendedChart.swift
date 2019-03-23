//
//  AnyExtendedChart.swift
//  Agile diary
//
//  Created by Илья Харабет on 23/03/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

protocol AnyExtendedChart: AnyObject {
    var sprint: Sprint? { get set }
}
