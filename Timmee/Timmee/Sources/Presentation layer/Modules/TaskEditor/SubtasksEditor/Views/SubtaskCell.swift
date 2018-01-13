//
//  SubtaskCell.swift
//  Timmee
//
//  Created by Ilya Kharabet on 06.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import struct Foundation.IndexPath
import SwipeCellKit

final class SubtaskCell: SwipeTableViewCell {
    
    @IBOutlet fileprivate weak var checkBox: InversedCheckBox! {
        didSet {
            checkBox.didChangeCkeckedState = { [weak self] _ in
                self?.onDone?()
            }
        }
    }
    @IBOutlet fileprivate weak var titleView: GrowingTextView! {
        didSet {
            titleView.textView.delegate = self
            titleView.textView.isEditable = false
            titleView.textView.isSelectable = false
            titleView.delegates.didChangeHeight = { [unowned self] height in
                self.onChangeHeight?(height)
            }
            addTapGestureRecognizer()
        }
    }
    
    var isDone: Bool = false {
        didSet {
            checkBox.isChecked = isDone
            updateTitle(title)
            titleView.isUserInteractionEnabled = !isDone
        }
    }
    
    var title: String {
        get { return titleView.textView.attributedText.string }
        set { updateTitle(newValue) }
    }
    
    fileprivate var titleBeforeEditing: String?
    
    var onBeginEditing: (() -> Void)?
    var onDone: (() -> Void)?
    var onChangeTitle: ((String) -> Void)?
    var onChangeHeight: ((CGFloat) -> Void)?
    
    @objc func beginEditing() {
        self.hideSwipe(animated: true)
        titleView.textView.isEditable = true
        titleView.textView.isSelectable = true
        titleView.becomeFirstResponder()
        onBeginEditing?()
    }
    
    fileprivate func updateTitle(_ title: String) {
        let attributes = isDone ? SubtaskCell.doneAttributes : SubtaskCell.activeAttributes
        titleView.textView.attributedText = NSAttributedString(string: title,
                                                               attributes: attributes)
    }
    
    static var doneAttributes: [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.light),
        NSAttributedStringKey.foregroundColor: AppTheme.current.secondaryTintColor,
        NSAttributedStringKey.strikethroughStyle: NSUnderlineStyle.styleSingle.rawValue
    ]
    
    static var activeAttributes = [
        NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.light),
        NSAttributedStringKey.foregroundColor: AppTheme.current.tintColor
    ]
    
}

extension SubtaskCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        titleBeforeEditing = title
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        titleView.textView.isEditable = false
        titleView.textView.isSelectable = false
        if textView.attributedText.string.isEmpty {
            title = titleBeforeEditing ?? ""
        }
        onChangeTitle?(textView.attributedText.string)
    }

}

fileprivate extension SubtaskCell {
    
    func addTapGestureRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(beginEditing))
        titleView.addGestureRecognizer(recognizer)
    }
    
}


final class SubtaskCellActionsProvider {
    
    var onDelete: ((IndexPath) -> Void)?
    
    static var backgroundColor: UIColor {
        return .clear
    }
    
    fileprivate lazy var swipeTableOptions: SwipeTableOptions = {
        var options = SwipeTableOptions()
        options.expansionStyle = nil
        options.transitionStyle = SwipeTransitionStyle.drag
        options.backgroundColor = SubtaskCellActionsProvider.backgroundColor
        return options
    }()
    
    fileprivate lazy var swipeDeleteAction: SwipeAction = {
        let deleteAction = SwipeAction(style: .default,
                                       title: "delete".localized,
                                       handler:
            { [weak self] (action, indexPath) in
                self?.onDelete?(indexPath)
                action.fulfill(with: .delete)
        })
        deleteAction.image = UIImage(named: "trash")
        deleteAction.textColor = AppTheme.current.redColor
        deleteAction.title = nil
        deleteAction.backgroundColor = SubtaskCellActionsProvider.backgroundColor
        deleteAction.transitionDelegate = nil
        return deleteAction
    }()
    
}

extension SubtaskCellActionsProvider: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        switch orientation {
        case .left: return nil
        case .right: return [swipeDeleteAction]
        }
    }
    
    func tableView(_ tableView: UITableView,
                   editActionsOptionsForRowAt indexPath: IndexPath,
                   for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        return swipeTableOptions
    }
    
}
