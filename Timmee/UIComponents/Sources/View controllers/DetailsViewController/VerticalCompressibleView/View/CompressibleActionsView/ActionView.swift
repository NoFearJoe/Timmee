//
//  ActionView.swift
//  DetailsUIKit
//
//  Created by a.stashevskiy on 19.04.2018.
//

import UIKit

public class ActionView: UIView {

    // MARK: Public data structures

    public typealias Action = (ActionView) -> Void

    public struct Model {
        let title: NSAttributedString
        let image: UIImage

        let action: Action

        public init(title: NSAttributedString,
                    image: UIImage,
                    action: @escaping Action) {
            self.title = title
            self.image = image
            self.action = action
        }
    }

    public struct Style {
        let contentColor: UIColor?
        let backgroundColor: UIColor?
        let width: CGFloat?
        let topInset: CGFloat
        let bottomInset: CGFloat

        public init(contentColor: UIColor? = nil,
                    backgroundColor: UIColor? = nil,
                    width: CGFloat? = nil,
                    topInset: CGFloat = 0,
                    bottomInset: CGFloat = 0) {
            self.contentColor = contentColor
            self.backgroundColor = backgroundColor
            self.width = width
            self.topInset = topInset
            self.bottomInset = bottomInset
        }
    }

    // MARK: Constants

    private enum Constants {

        static let highlightAlpha: CGFloat = 0.7
        static let disabledAlpha: CGFloat = 0.5
        static let alphaAnimationDuration: TimeInterval = 0.2

        enum Title {
            static let numberOfLines = 2
        }
    }

    // MARK: Outlets

    @IBOutlet private weak var actualView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var iconTopSpacing: NSLayoutConstraint!
    @IBOutlet private weak var labelBottomSpacing: NSLayoutConstraint!

    // MARK: Public properties

    public var isHighlighted: Bool = false {
        didSet {
            updateControlState()
        }
    }

    public override var isUserInteractionEnabled: Bool {
        didSet {
            updateControlState()
        }
    }

    // MARK: Private Properties

    private lazy var widthConstraint = self.widthAnchor.constraint(equalToConstant: 0)

    private var action: Action?

    // MARK: Lifecycle

    override public func awakeFromNib() {
        super.awakeFromNib()

        setupView()
    }

    // MARK: Action

    @objc private func didTapOnView(_ sender: UIGestureRecognizer) {
        switch sender.state {
        case .began:
            isHighlighted = true

        case .ended:
            isHighlighted = false
            action?(self)

        case .cancelled:
            isHighlighted = false

        default:
            break
        }
    }

    // MARK: Private

    private func setupView() {
        backgroundColor = .clear
        actualView.backgroundColor = .clear

        imageView.image = nil
        imageView.layer.cornerRadius = imageView.bounds.height / 2

        titleLabel.text = nil
        titleLabel.numberOfLines = Constants.Title.numberOfLines
        titleLabel.textAlignment = .center

        let gesture = TouchGestureRecognizer(target: self, action: #selector(didTapOnView(_:)))
        addGestureRecognizer(gesture)
    }

    private func updateControlState() {
        var alpha: CGFloat = 1.0
        if !isUserInteractionEnabled {
            alpha = Constants.disabledAlpha
        } else if isHighlighted {
            alpha = Constants.highlightAlpha
        }

        UIView.animate(withDuration: Constants.alphaAnimationDuration) {
            self.actualView.alpha = alpha
        }
    }
}

// MARK: - ConfigurableView

extension ActionView: ConfigurableView {
    
    public func configure(with model: Model) {
        titleLabel.attributedText = model.title

        imageView.image = model.image

        action = model.action
    }
}

// MARK: - StyleAvailableView

extension ActionView: StyleAvailableView {

    public func apply(_ style: Style) {
        imageView.backgroundColor = style.backgroundColor
        imageView.tintColor = style.contentColor

        if let width = style.width {
            widthConstraint.constant = width
            widthConstraint.isActive = true
        } else {
            widthConstraint.isActive = false
        }
        iconTopSpacing.constant = style.topInset
        labelBottomSpacing.constant = style.bottomInset
    }
}
