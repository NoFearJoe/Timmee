//
//  GoalCreationStageCell.swift
//  Agile diary
//
//  Created by Илья Харабет on 31/12/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

final class GoalCreationStageCell: SwipeTableViewCell {
    
    static let reuseIdentifier = "GoalCreationStageCell"
    
    var stageNumber: Int = 1 {
        didSet {
            stageNumberLabel.text = "#\(stageNumber)"
        }
    }
    
    var title: String {
        get { return titleView.textView.text }
        set { titleView.textView.text = newValue }
    }
    
    var onChangeTitle: ((String) -> Void)?
    var onChangeHeight: ((CGFloat) -> Void)?
    
    private lazy var titleView: GrowingTextView = {
        let titleView = GrowingTextView()
        
        titleView.textView.delegate = self
        titleView.textView.isEditable = false
        titleView.textView.isSelectable = false
        titleView.clipsToBounds = true
        titleView.textView.textContainerInset.left = -4
        titleView.maxNumberOfLines = 5
        titleView.delegates.didChangeHeight = { [unowned self] height in
            self.onChangeHeight?(height)
        }
        
        return titleView
    }()
    
    private let stageNumberLabel = UILabel()
    
    private var titleBeforeEditing: String?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupLayout()
        applyAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyAppearance() {
        titleView.textView.textColor = AppTheme.current.colors.activeElementColor
        titleView.textView.keyboardAppearance = AppTheme.current.keyboardStyleForTheme
        
        stageNumberLabel.textColor = AppTheme.current.colors.inactiveElementColor
        stageNumberLabel.font = AppTheme.current.fonts.regular(15)
    }
    
}

extension GoalCreationStageCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        titleBeforeEditing = title
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        titleView.textView.isEditable = false
        titleView.textView.isSelectable = false
        if textView.text.isEmpty {
            title = titleBeforeEditing ?? ""
        }
        guard title != titleBeforeEditing else { return }
        onChangeTitle?(textView.attributedText.string)
    }
    
}

private extension GoalCreationStageCell {
    
    func addTapGestureRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(beginEditing))
        titleView.addGestureRecognizer(recognizer)
    }
    
    @objc func beginEditing() {
        self.hideSwipe(animated: true)
        titleView.textView.isEditable = true
        titleView.textView.isSelectable = true
        titleView.becomeFirstResponder()
    }
    
}

private extension GoalCreationStageCell {
    
    func setupViews() {
        selectionStyle = .none
        
        contentView.addSubview(titleView)
        contentView.addSubview(stageNumberLabel)
        
        addTapGestureRecognizer()
    }
    
    func setupLayout() {
        stageNumberLabel.width(28)
        [stageNumberLabel.leading(), stageNumberLabel.centerY()].toSuperview()
        stageNumberLabel.trailingToLeading(4).to(titleView, addTo: contentView)
        
        [titleView.top(), titleView.centerY(), titleView.trailing()].toSuperview()
    }
    
}
