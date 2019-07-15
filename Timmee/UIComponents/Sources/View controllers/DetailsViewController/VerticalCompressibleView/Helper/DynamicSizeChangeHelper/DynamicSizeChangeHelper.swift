//
//  DynamicSizeChangeHelper.swift
//  MobileBank
//
//  Created by g.novik on 18.01.2018.
//  Copyright © 2018 АО «Тинькофф Банк», лицензия ЦБ РФ № 2673. All rights reserved.
//

import UIKit

/// Вспомогательный объект для расчета изменения размера
public class DynamicSizeChangeHelper: IDynamicSizeChangeHelper {

    public var maximum: CGFloat
    public var minimum: CGFloat

    private var minMaxDifference: CGFloat {
        return maximum - minimum
    }

    private var minMaxDivision: CGFloat {
        return minimum / maximum
    }

    // MARK: - IDynamicSizeChangeHelper

    required public init(maximum: CGFloat, minimum: CGFloat) {
        self.maximum = maximum
        self.minimum = minimum
    }

    public func size(for state: CGFloat) -> CGFloat {
        let state = normalizedState(from: state)

        return minimum + minMaxDifference * state
    }

    public func scale(for state: CGFloat) -> CGFloat {
        let state = normalizedState(from: state)

        return minMaxDivision + (minMaxDifference / maximum) * state
    }

    public func alpha(for state: CGFloat) -> CGFloat {
        return max(0, (state - 0.5) * 2)
    }

    // MARK: - Private

    private func normalizedState(from state: CGFloat) -> CGFloat {
        var stateInternal: CGFloat

        if state < .minimizedState {
            stateInternal = .minimizedState
            assert(false)
        } else if state > .maximizedState {
            stateInternal = .maximizedState
            assert(false)
        } else {
            stateInternal = state
        }

        return stateInternal
    }
}

// MARK: - Constants

extension CGFloat {
    
    static let minimizedState: CGFloat = 0
    static let maximizedState: CGFloat = 1
}
