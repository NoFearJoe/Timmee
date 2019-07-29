//
//  DiaryEntryCreationView.swift
//  Agile diary
//
//  Created by i.kharabet on 25/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import Workset
import UIComponents

final class DiaryEntryCreationView: UIView {
    
    var onCreate: ((String) -> Void)?
    var onAttachment: (() -> Void)?
    
    private let textView = GrowingTextView(frame: .zero)
    let attachmentButton = UIButton(type: .custom)
    private let createButton = FloatingButton(frame: .zero)
    
    init() {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = AppTheme.current.colors.foregroundColor
        
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    func clear() {
        textView.textView.text = nil
    }
    
    private func setupSubviews() {
        addSubview(textView)
        setupTextField()
        
        addSubview(attachmentButton)
        attachmentButton.setImage(UIImage(named: "attachments"), for: .normal)
        attachmentButton.tintColor = AppTheme.current.colors.activeElementColor
        attachmentButton.addTarget(self, action: #selector(onTapToAttachmentButton), for: .touchUpInside)
        
        addSubview(createButton)
        createButton.isHidden = true
        createButton.setImage(UIImage(named: "plus"), for: .normal)
        createButton.addTarget(self, action: #selector(onTapToCreateButton), for: .touchUpInside)
        createButton.colors = FloatingButton.Colors(tintColor: .white,
                                                    backgroundColor: AppTheme.current.colors.mainElementColor,
                                                    secondaryBackgroundColor: AppTheme.current.colors.inactiveElementColor)
    }
    
    private func setupTextField() {
        textView.textView.delegate = self
        textView.maxNumberOfLines = 10
        textView.showsVerticalScrollIndicator = false
        textView.placeholderAttributedText
            = NSAttributedString(string: "diary_entry_creation_placeholder".localized,
                                 attributes: [.font: AppTheme.current.fonts.regular(16),
                                              .foregroundColor: AppTheme.current.colors.inactiveElementColor])
        
        setupTextObserver()
        
        textView.textView.textColor = AppTheme.current.colors.activeElementColor
        textView.textView.font = AppTheme.current.fonts.regular(16)
        textView.textView.keyboardAppearance = AppTheme.current.keyboardStyleForTheme
    }
    
    private func setupTextObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChange),
                                               name: UITextView.textDidChangeNotification,
                                               object: textView.textView)
    }
    
    private func setupConstraints() {
        attachmentButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        [attachmentButton.leading(8), attachmentButton.top(8)].toSuperview()
        attachmentButton.width(36)
        attachmentButton.height(36)
        
        [createButton.top(8), createButton.trailing(8)].toSuperview()
        createButton.width(36)
        createButton.height(36)
        
        [textView.top(8), textView.bottom(8)].toSuperview()
        textView.leadingToTrailing(8).to(attachmentButton, addTo: self)
        textView.trailingToLeading(-8).to(createButton, addTo: self)
    }
    
    @objc private func textDidChange(notification: Notification) {
        createButton.isHidden = textView.textView.text.isEmpty
    }
    
    @objc private func onTapToCreateButton() {
        guard let text = textView.textView.text.trimmed.nilIfEmpty else { return }
        onCreate?(text)
    }
    
    @objc private func onTapToAttachmentButton() {
        onAttachment?()
    }
    
}

extension DiaryEntryCreationView: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.textView.setContentOffset(.zero, animated: true)
    }
    
}
