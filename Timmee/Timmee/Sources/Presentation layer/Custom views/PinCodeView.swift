//
//  PinCodeView.swift
//  Test
//
//  Created by i.kharabet on 18.08.17.
//  Copyright © 2017 i.kharabet. All rights reserved.
//

import UIKit

protocol PinCodeViewDelegate: class {
    func pinCodeViewDidFilled(_ pinCodeView: PinCodeView)
}

final class PinCodeView: UIView {

    fileprivate enum State {
        case empty
        case filled(count: Int)
        case right
        case wrong
    }
    
    @IBInspectable var emptyDotColor: UIColor = .gray
    @IBInspectable var filledDotColor: UIColor = .black
    @IBInspectable var rightPinCodeDotColor: UIColor = .green
    @IBInspectable var wrongPinCodeDotColor: UIColor = .red
    
    @IBInspectable var pinCodeLength: Int = 4
    
    @IBInspectable var dotSize: CGFloat = 12
    
    fileprivate var state: State = .empty {
        didSet {
            updateDotsColor()
        }
    }
    
    weak var delegate: PinCodeViewDelegate?
    
    fileprivate var dots: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createDots()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createDots()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutDots()
    }
    
}

extension PinCodeView {

    // Заполняет следующую точку
    func fillNext() {
        switch state {
        case .empty: state = .filled(count: 1)
        case .filled(let count): state = .filled(count: min(count + 1, pinCodeLength))
        default: break
        }
        checkIsFilled()
    }
    
    // Заполняет все точки
    func fillAll() {
        state = .filled(count: pinCodeLength)
        checkIsFilled()
    }
    
    // Показывает правильный ввод кода
    func showPinCodeRight() {
        state = .right
    }
    
    // Показывает неправильный ввод кода
    func showPinCodeWrong() {
        state = .wrong
    }
    
    func clear() {
        state = .empty
    }
    
    func removeLast() {
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
