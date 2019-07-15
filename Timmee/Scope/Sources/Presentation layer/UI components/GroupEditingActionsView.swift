//
//  GroupEditingActionsView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 04.11.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

enum GroupEditingCompletionAction {
    case complete
    case recover
    
    var title: String {
        switch self {
        case .complete: return "complete".localized
        case .recover: return "restore".localized
        }
    }
    
    var image: UIImage {
        switch self {
        case .complete: return #imageLiteral(resourceName: "checkmark")
        case .recover: return #imageLiteral(resourceName: "repeat")
        }
    }
}

enum GroupEditingAction {
    case delete
    case complete
    case move
}

enum TargetGroupEditingAction {
    case delete
    case complete
    case move(list: List)
}

final class GroupEditingActionsView: UIView {
    
    var onAction: ((GroupEditingAction) -> Void)?
    
    @IBOutlet private var deleteActionView: GroupEditingActionView! {
        didSet {
            deleteActionView.image = #imageLiteral(resourceName: "trash")
            deleteActionView.title = "remove".localized
            deleteActionView.titleColor = AppTheme.current.redColor
            deleteActionView.onTap = { [unowned self] in self.didSelectAction(.delete) }
        }
    }
    @IBOutlet private var completeActionView: GroupEditingActionView! {
        didSet {
            completeActionView.title = GroupEditingCompletionAction.complete.title
            completeActionView.image = GroupEditingCompletionAction.complete.image
            completeActionView.titleColor = AppTheme.current.greenColor
            completeActionView.onTap = { [unowned self] in self.didSelectAction(.complete) }
        }
    }
    @IBOutlet private var moveActionView: GroupEditingActionView! {
        didSet {
            moveActionView.image = #imageLiteral(resourceName: "mailListIcon")
            moveActionView.title = "move".localized
            moveActionView.titleColor = AppTheme.current.blueColor
            moveActionView.onTap = { [unowned self] in self.didSelectAction(.move) }
        }
    }
    
    private var isVisible: Bool = true
    private var isEnabled: Bool = true
    
    private func didSelectAction(_ action: GroupEditingAction) {
        onAction?(action)
    }
    
    func setVisible(_ isVisible: Bool, animated: Bool) {
        guard isVisible != self.isVisible else { return }
        self.isVisible = isVisible
        
        let animations = {
            [self.deleteActionView, self.completeActionView, self.moveActionView]
                .forEach { view in
                    view?.alpha = isVisible ? (self.isEnabled ? 1 : 0.5) : 0
                    view?.transform = isVisible ? .identity : .init(scaleX: 0.1, y: 0.1)
            }
        }
        
        if isVisible {
            isHidden = false
        }
        
        if animated {
            UIView.animate(withDuration: 0.33,
                           delay: 0,
                           options: [.beginFromCurrentState, .curveEaseOut],
                           animations: animations) { finished in
                            if !isVisible {
                                self.isHidden = true
                            }
            }
        } else {
            animations()
            if !isVisible {
                isHidden = true
            }
        }
    }
    
    func setEnabled(_ isEnabled: Bool) {
        guard isEnabled != self.isEnabled else { return }
        self.isEnabled = isEnabled
        
        [self.deleteActionView, self.completeActionView, self.moveActionView]
            .forEach { view in
                view?.isUserInteractionEnabled = isEnabled
                view?.alpha = isEnabled ? 1 : 0.5
        }
    }
    
    func updateAction(_ action: GroupEditingAction,
                      withTitle title: String,
                      andImage image: UIImage) {
        switch action {
        case .delete:
            deleteActionView.title = title
            deleteActionView.iconView.image = image
        case .complete:
            completeActionView.title = title
            completeActionView.iconView.image = image
        case .move:
            moveActionView.title = title
            moveActionView.iconView.image = image
        }
    }
    
}

final class GroupEditingActionView: UIView {
    
    var onTap: (() -> Void)?
    
    @IBOutlet fileprivate var iconView: UIImageView! {
        didSet {
            iconView.image = image
            iconView.tintColor = AppTheme.current.backgroundTintColor
        }
    }
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.text = title
            titleLabel.textColor = titleColor
        }
    }
    
    var title: String = "" {
        didSet {
            titleLabel?.text = title
        }
    }
    
    var titleColor: UIColor = .clear {
        didSet {
            titleLabel?.textColor = titleColor
        }
    }
    
    var image: UIImage = UIImage() {
        didSet {
            iconView?.image = image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTapGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addTapGestureRecognizer()
    }
    
    private func addTapGestureRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        self.addGestureRecognizer(recognizer)
    }
    
    @objc private func tap() {
        onTap?()
    }
    
}
