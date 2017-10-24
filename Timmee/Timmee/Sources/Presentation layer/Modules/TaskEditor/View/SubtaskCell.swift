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
    @IBOutlet fileprivate weak var titleView: TextView! {
        didSet {
            titleView.delegate = self
            titleView.onChangeContentHeight = { [weak self] height in
                self?.onChangeHeight?(height)
            }
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
        get { return titleView.attributedText.string }
        set { updateTitle(newValue) }
    }
    
    fileprivate var titleBeforeEditing: String?
    
    var onBeginEditing: (() -> Void)?
    var onDone: (() -> Void)?
    var onChangeTitle: ((String) -> Void)?
    var onChangeHeight: ((CGFloat) -> Void)?
    
    func beginEditing() {
        titleView.isEditable = true
        titleView.isSelectable = true
        titleView.becomeFirstResponder()
        onBeginEditing?()
    }
    
    fileprivate func updateTitle(_ title: String) {
        let attributes = isDone ? SubtaskCell.doneAttributes : SubtaskCell.activeAttributes
        titleView.attributedText = NSAttributedString(string: title,
                                                      attributes: attributes)
    }
    
    static var doneAttributes: [String: Any] = [
        NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightLight),
        NSForegroundColorAttributeName: AppTheme.current.scheme.secondaryTintColor,
        NSStrikethroughStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue
    ]
    
    static var activeAttributes = [
        NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightLight),
        NSForegroundColorAttributeName: AppTheme.current.scheme.tintColor
    ]
    
}

extension SubtaskCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        titleBeforeEditing = title
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        titleView.isEditable = false
        titleView.isSelectable = false
        if textView.attributedText.string.isEmpty {
            title = titleBeforeEditing ?? ""
        }
        onChangeTitle?(textView.attributedText.string)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        textView.layoutIfNeeded()
        return true
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
        deleteAction.textColor = AppTheme.current.scheme.redColor
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
