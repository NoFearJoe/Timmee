//
//  CompressibleActionsView.swift
//  DetailsUIKit
//
//  Created by a.stashevskiy on 19.04.2018.
//

import UIKit

public final class CompressibleActionsView: UIView {

    // MARK: Model

    public struct Style {
        let backgroundColor: UIColor
        let actionsSpacing: CGFloat

        public init(backgroundColor: UIColor = .clear,
                    actionsSpacing: CGFloat = 0) {
            self.backgroundColor = backgroundColor
            self.actionsSpacing = actionsSpacing
        }
    }

    // MARK: Outlets

    @IBOutlet private weak var actualView: UIView!
    @IBOutlet private weak var stackView: UIStackView!

    // MARK: Private variables

    private var actionsHeight: CGFloat = 0

    // MARK: Lifecycle

    public override func awakeFromNib() {
        super.awakeFromNib()

        setupView()
    }

    // MARK: Public

    public func setActionViews(_ actionViews: [ActionView]) {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        actionViews.forEach(stackView.addArrangedSubview)
    }

    // MARK: Private

    private func setupView() {
        backgroundColor = .clear
        actualView.backgroundColor = .clear
    }
}

// MARK: - VerticalCompressibleView

extension CompressibleActionsView: VerticalCompressibleView {

    public var maximizedStateHeight: CGFloat {
        return actionsHeight
    }

    public var minimizedStateHeight: CGFloat {
        return actionsHeight
    }

    public func changeCompression(to state: CGFloat) {
        // unused
    }

    public func updateHeights() {
        stackView.layoutIfNeeded()
        actionsHeight = stackView.arrangedSubviews.map { $0.frame.height }.max() ?? 0
    }
}

// MARK: - StyleAvailableView

extension CompressibleActionsView: StyleAvailableView {

    public func apply(_ style: CompressibleActionsView.Style) {
        actualView.backgroundColor = style.backgroundColor
        stackView.spacing = style.actionsSpacing
    }
}
