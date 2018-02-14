//
//  SwipableCollectionViewCell.swift
//  Timmee
//
//  Created by i.kharabet on 01.02.18.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

struct SwipeCollectionAction {
    let icon: UIImage
    let tintColor: UIColor
    let action: (IndexPath) -> Void
}

protocol SwipableCollectionViewCellActionsProvider: class {
    func actions(forCellAt indexPath: IndexPath) -> [SwipeCollectionAction]
}

class SwipableCollectionViewCell: BaseRoundedCollectionViewCell {
    
    weak var actionsProvider: SwipableCollectionViewCellActionsProvider?
    
    private var actionButtonsContainer: UIView?
    private var actionButtons: [UIButton] = []
    
    private weak var collectionView: UICollectionView?
    
    private var snapshotCenter: CGPoint = .zero
    private var currentSwipeOffset: CGFloat = 0
    
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        recognizer.delegate = self
        return recognizer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTapGestureRecognizer()
        addPanGestureRecognizer()
        clipsToBounds = false
        isExclusiveTouch = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addTapGestureRecognizer()
        addPanGestureRecognizer()
        clipsToBounds = false
        isExclusiveTouch = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        snapshotCenter = .zero
        currentSwipeOffset = 0
        
        if isHalfSwiped() {
            hide()
        }
    }
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        var view: UIView = self
        while let superview = view.superview {
            view = superview
            
            if let collectionView = view as? UICollectionView {
                self.collectionView = collectionView
                
                collectionView.panGestureRecognizer.removeTarget(self, action: nil)
                collectionView.panGestureRecognizer.addTarget(self, action: #selector(handleCollectionPan(gesture:)))
                return
            }
        }
    }
    
    private func addPanGestureRecognizer() {
        addGestureRecognizer(panGestureRecognizer)
    }
    
    private func addTapGestureRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
    }
    
    @objc private func onPan(_ recognizer: UIPanGestureRecognizer) {
        guard containsActions else { return }
        
        switch recognizer.state {
        case .began:
            addActionButtons()
            hideOtherSwipedCell()
            if snapshotCenter == .zero {
                snapshotCenter = center
            }
            collectionView?.swipedCell = self
        case .changed:
            guard snapshotCenter != .zero else { return }
            guard let container = actionButtonsContainer else { return }
            let translation = recognizer.translation(in: self)
            let x = min(snapshotCenter.x, max(self.center.x + translation.x, snapshotCenter.x - container.frame.width))
            let center = CGPoint(x: x, y: self.center.y)
            recognizer.setTranslation(.zero, in: self)
            self.center = center
            currentSwipeOffset = max(0, min(container.frame.width, currentSwipeOffset - translation.x))
        case .ended, .cancelled:
            let velocity = recognizer.velocity(in: self)
            if isHalfSwiped() || shouldShowActions(velocity: velocity) {
                show(animated: true)
            }
            if !isHalfSwiped() || shouldHideActions(velocity: velocity) {
                hide(animated: true)
            }
            
            if snapshotCenter == center {
                snapshotCenter = .zero
            }
        default: break
        }
    }
    
    @objc func onTap(_ gesture: UITapGestureRecognizer) {
        if currentSwipeOffset > 0 || isHalfSwiped() {
            hide(animated: true)
        }
    }
    
    @objc func handleCollectionPan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began, isHalfSwiped() {
            hide(animated: true)
        }
    }
    
    private func addActionButtons() {
        guard actionButtonsContainer == nil else { return }
        
        actionButtons = makeActionButtons()
        
        guard !actionButtons.isEmpty else { return }
        
        actionButtonsContainer = UIView(frame: .zero)
        contentView.addSubview(actionButtonsContainer!)
        contentView.sendSubview(toBack: actionButtonsContainer!)
        actionButtonsContainer!.top().toSuperview()
        actionButtonsContainer!.bottom().toSuperview()
        actionButtonsContainer!.leadingToTrailing().toSuperview()
        actionButtonsContainer!.backgroundColor = .clear
        
        for (index, button) in actionButtons.enumerated() {
            actionButtonsContainer!.addSubview(button)
            button.top().toSuperview()
            button.bottom().toSuperview()
            button.width(frame.height * 1.5)
            if index == 0 {
                button.leading().toSuperview()
            } else {
                button.leadingToTrailing().to(actionButtons.item(at: index - 1)!, addTo: actionButtonsContainer)
            }
            if index == actionButtons.count - 1 {
                button.trailing().toSuperview()
            }
        }
    }
    
    private func removeActionButtons() {
        actionButtons.forEach {
            $0.removeFromSuperview()
        }
        actionButtons.removeAll()
        actionButtonsContainer?.removeFromSuperview()
        actionButtonsContainer = nil
    }
    
    private func makeActionButtons() -> [UIButton] {
        guard let indexPath = collectionView?.indexPath(for: self) else { return [] }
        guard let actions = actionsProvider?.actions(forCellAt: indexPath), !actions.isEmpty else { return [] }
        
        return actions.map { action in
            let button = UIButton(frame: .zero)
            button.addTarget(self, action: #selector(onTapToActionButton(_:)), for: .touchUpInside)
            button.setImage(action.icon, for: .normal)
            button.tintColor = action.tintColor
            return button
        }
    }
    
    @objc private func onTapToActionButton(_ button: UIButton) {
        guard let index = actionButtons.index(of: button) else { return }
        guard let indexPath = collectionView?.indexPath(for: self) else { return }
        guard let actions = actionsProvider?.actions(forCellAt: indexPath), !actions.isEmpty else { return }
        guard let action = actions.item(at: index) else { return }
        
        action.action(indexPath)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let actionsViewBounds = actionButtonsContainer?.bounds ?? .zero
        let fullFrame = CGRect(x: bounds.width, y: 0, width: actionsViewBounds.width, height: actionsViewBounds.height)
        
        if fullFrame.contains(point) {
            let convertedPoint = actionButtonsContainer?.convert(point, from: self) ?? .zero
            return actionButtonsContainer?.hitTest(convertedPoint, with: event)
        }
        return super.hitTest(point, with: event)
    }
    
    private func hideOtherSwipedCell() {
        guard let collectionView = collectionView else { return }
        guard let swipedCell = collectionView.swipedCell else { return }
        guard swipedCell != self else { return }
        swipedCell.hide(animated: true)
    }
    
    private var containsActions: Bool {
        guard let indexPath = collectionView?.indexPath(for: self) else { return false }
        guard let actions = actionsProvider?.actions(forCellAt: indexPath) else { return false }
        return !actions.isEmpty
    }
    
}

// MARK: - Show/Hide
extension SwipableCollectionViewCell {
    
    func show(animated: Bool) {
        collectionView?.isUserInteractionEnabled = false
        UIView.animate(withDuration: animated ? 0.1 : 0, animations: {
            guard self.snapshotCenter != .zero else { return }
            guard let container = self.actionButtonsContainer else { return }
            let x = self.snapshotCenter.x - container.frame.width
            self.center = CGPoint(x: x, y: self.center.y)
        }) { _ in
            self.collectionView?.isUserInteractionEnabled = true
        }
    }
    
    func hide(animated: Bool = false) {
        guard snapshotCenter != .zero else { return }
        panGestureRecognizer.isEnabled = false
        panGestureRecognizer.isEnabled = true
        collectionView?.isUserInteractionEnabled = false
        UIView.animate(withDuration: animated ? 0.1 : 0, animations: {
            guard self.snapshotCenter != .zero else { return }
            self.center = self.snapshotCenter
        }) { _ in
            self.currentSwipeOffset = 0
            self.removeActionButtons()
            if self.collectionView?.swipedCell == self {
                self.collectionView?.swipedCell = nil
            }
            self.collectionView?.isUserInteractionEnabled = true
        }
    }
    
    private func shouldShowActions(velocity: CGPoint) -> Bool {
        guard let container = actionButtonsContainer else { return false }
        return abs(velocity.x) > container.bounds.width * 0.5 && velocity.x < 0
    }
    
    private func shouldHideActions(velocity: CGPoint) -> Bool {
        guard let container = actionButtonsContainer else { return false }
        return abs(velocity.x) > container.bounds.width * 0.5 && velocity.x > 0
    }
    
    private func isHalfSwiped() -> Bool {
        guard let container = actionButtonsContainer else { return false }
        let halfWidth = container.frame.width * 0.5
        return currentSwipeOffset >= halfWidth
    }
    
}

extension SwipableCollectionViewCell: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panRecognizer.translation(in: self)
            return containsActions
                && abs(translation.x) > abs(translation.y)
        }
        if gestureRecognizer is UITapGestureRecognizer {
            return currentSwipeOffset > 0
                && (panGestureRecognizer.state == UIGestureRecognizerState.possible || panGestureRecognizer.state == UIGestureRecognizerState.failed)
        }
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !(gestureRecognizer is UIPanGestureRecognizer) && !(gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UITapGestureRecognizer)
    }
    
}

private extension UICollectionView {
    
    static var currentCell = "swiped_cell"
    
    var swipedCell: SwipableCollectionViewCell? {
        get {
            return objc_getAssociatedObject(self, &UICollectionView.currentCell) as? SwipableCollectionViewCell
        }
        set {
            objc_setAssociatedObject(self,
                                     &UICollectionView.currentCell,
                                     newValue,
                                     .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
}

extension UICollectionView {
    
    func hideSwipedCell() {
        swipedCell?.hide()
    }
    
}
