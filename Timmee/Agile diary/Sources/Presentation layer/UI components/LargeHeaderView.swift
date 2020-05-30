//
//  LargeHeaderView.swift
//  Agile diary
//
//  Created by i.kharabet on 13.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

class LargeHeaderView: UIView {
    
    @IBOutlet var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = AppTheme.current.colors.activeElementColor
            titleLabel.font = AppTheme.current.fonts.bold(34)
        }
    }
    @IBOutlet var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.textColor = AppTheme.current.colors.activeElementColor
            subtitleLabel.font = AppTheme.current.fonts.regular(14)
        }
    }
    @IBOutlet var leftButton: UIButton? {
        didSet {
            leftButton?.tintColor = AppTheme.current.colors.activeElementColor
        }
    }
    @IBOutlet var rightButton: UIButton? {
        didSet {
            rightButton?.tintColor = AppTheme.current.colors.activeElementColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupAppearance()
    }
    
    private func setupAppearance() {
        backgroundColor = AppTheme.current.colors.foregroundColor
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setLineWidth(0.5)
        context.setStrokeColor(AppTheme.current.colors.mainElementColor.cgColor)
        context.move(to: CGPoint(x: 0, y: rect.maxY - 0.5))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 0.5))
        context.strokePath()
    }
    
}

final class DefaultLargeHeaderView: LargeHeaderView {
    
    var onTapLeftButton: (() -> Void)?
    var onTapRightButton: (() -> Void)?
    
    private let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    func configure(title: String, subtitle: NSAttributedString?, onTapLeftButton: (() -> Void)?, onTapRightButton: (() -> Void)?) {
        titleLabel.text = title
        subtitleLabel.attributedText = subtitle
        subtitleLabel.isHidden = subtitle == nil
        self.onTapLeftButton = onTapLeftButton
        self.onTapRightButton = onTapRightButton
    }
    
    func setupViews() {
        leftButton = UIButton()
        leftButton?.setImage(UIImage(named: "cross"), for: .normal)
        leftButton?.addTarget(self, action: #selector(didTapLeftButton), for: .touchUpInside)
        addSubview(leftButton!)
        leftButton!.leading(15).toSuperview()
        if #available(iOS 11.0, *) {
            leftButton?.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12).isActive = true
        } else {
            leftButton?.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        }
        
        rightButton = UIButton()
        rightButton?.setTitle("done".localized, for: .normal)
        rightButton?.addTarget(self, action: #selector(didTapRightButton), for: .touchUpInside)
        addSubview(rightButton!)
        rightButton!.trailing(15).toSuperview()
        if #available(iOS 11.0, *) {
            rightButton?.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12).isActive = true
        } else {
            rightButton?.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
        }
        
        stackView.axis = .vertical
        stackView.spacing = 2
        addSubview(stackView)
        stackView.topToBottom(6).to(leftButton!, addTo: self)
        [stackView.leading(15), stackView.trailing(15), stackView.bottom(8)].toSuperview()
        
        titleLabel = UILabel()
        subtitleLabel = UILabel()
        subtitleLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
    }
    
    @objc private func didTapLeftButton() {
        onTapLeftButton?()
    }
    
    @objc private func didTapRightButton() {
        onTapRightButton?()
    }
    
}
