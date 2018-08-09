//
//  PinCodeView.swift
//  Test
//
//  Created by i.kharabet on 18.08.17.
//  Copyright © 2017 i.kharabet. All rights reserved.
//

import UIKit

public protocol PinCodeViewDelegate: class {
    func pinCodeViewDidFilled(_ pinCodeView: PinCodeView)
}

public final class PinCodeView: UIView {

    fileprivate enum State {
        case empty
        case filled(count: Int)
        case right
        case wrong
    }
    
    @IBInspectable public var emptyDotColor: UIColor = .gray {
        didSet { updateDotsColor() }
    }
    @IBInspectable public var filledDotColor: UIColor = .black {
        didSet { updateDotsColor() }
    }
    @IBInspectable public var rightPinCodeDotColor: UIColor = .green {
        didSet { updateDotsColor() }
    }
    @IBInspectable public var wrongPinCodeDotColor: UIColor = .red {
        didSet { updateDotsColor() }
    }
    
    @IBInspectable public var pinCodeLength: Int = 4
    
    @IBInspectable public var dotSize: CGFloat = 12
    
    fileprivate var state: State = .empty {
        didSet {
            updateDotsColor()
        }
    }
    
    public weak var delegate: PinCodeViewDelegate?
    
    fileprivate var dots: [UIView] = []
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        createDots()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createDots()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutDots()
    }
    
}

extension PinCodeView {

    // Заполняет следующую точку
    public func fillNext() {
        switch state {
        case .empty: state = .filled(count: 1)
        case .filled(let count): state = .filled(count: min(count + 1, pinCodeLength))
        default: break
        }
        checkIsFilled()
    }
    
    // Заполняет все точки
    public func fillAll() {
        state = .filled(count: pinCodeLength)
        checkIsFilled()
    }
    
    // Показывает правильный ввод кода
    public func showPinCodeRight() {
        state = .right
    }
    
    // Показывает неправильный ввод кода
    public func showPinCodeWrong() {
        state = .wrong
    }
    
    public func clear() {
        state = .empty
    }
    
    public func removeLast() {
        switch state {
        case .filled(let count):
            if count <= 1 {
                state = .empty
            } else {
                state = .filled(count: max(count - 1, 0))
            }
        case .wrong, .right:
            state = .filled(count: max(0, pinCodeLength - 1))
        default: break
        }
    }

}

fileprivate extension PinCodeView {
    
    // Создает новые точки и удаляет старые
    func createDots() {
        removeDots()
        
        (0..<pinCodeLength).forEach { index in
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.dotSize, height: self.dotSize))
            view.clipsToBounds = true
            view.backgroundColor = self.emptyDotColor
            view.layer.cornerRadius = self.dotSize * 0.5
            self.addSubview(view)
            self.dots.append(view)
        }
    }
    
    // Удаляет старые точки
    func removeDots() {
        dots.forEach({ $0.removeFromSuperview() })
        dots.removeAll()
    }
    
    func layoutDots() {
        let width = frame.width
        let centerY = frame.height * 0.5
        let spacing = (width - (dotSize * CGFloat(pinCodeLength))) / CGFloat(pinCodeLength - 1)
        
        for (index, dot) in dots.enumerated() {
            dot.frame = CGRect(x: CGFloat(index) * dotSize + CGFloat(index) * spacing,
                               y: centerY - dotSize * 0.5,
                               width: dotSize,
                               height: dotSize)
        }
    }
    
    func updateDotsColor() {
        switch state {
        case .empty:
            dots.forEach { dot in
                dot.backgroundColor = self.emptyDotColor
            }
        case .filled(let count):
            for (i, dot) in dots.enumerated() {
                dot.backgroundColor = i < count ? self.filledDotColor : self.emptyDotColor
            }
        case .right:
            UIView.animate(withDuration: 0.25) {
                self.dots.forEach { dot in
                    dot.backgroundColor = self.rightPinCodeDotColor
                }
            }
        case .wrong:
            UIView.animate(withDuration: 0.25) {
                self.dots.forEach { dot in
                    dot.backgroundColor = self.wrongPinCodeDotColor
                }
            }
        }
    }
    
    func checkIsFilled() {
        if case State.filled(let count) = state {
            if count >= pinCodeLength {
                delegate?.pinCodeViewDidFilled(self)
            }
        }
    }

}
