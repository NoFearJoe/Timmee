//
//  DiaryEntryAttachmentView.swift
//  Agile diary
//
//  Created by i.kharabet on 26/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import Workset
import UIComponents

final class DiaryEntryAttachmentView: UIView {
    
    var onClear: (() -> Void)?
    
    private let titleLabel = UILabel(frame: .zero)
    private let subjectLabel = UILabel(frame: .zero)
    private let clearButton = UIButton(type: .custom)
    
    init() {
        super.init(frame: .zero)
        
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        clearButton.layer.cornerRadius = clearButton.bounds.height / 2
    }
    
    func configure(attachment: DiaryEntry.Attachment, subject: String?) {
        if case .none = attachment {
            isHidden = true
        } else {
            isHidden = false
        }
        titleLabel.text = "attached".localized
        subjectLabel.text = subject
    }
    
    private func setupSubviews() {
        addSubview(titleLabel)
        titleLabel.font = AppTheme.current.fonts.medium(14)
        titleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        
        addSubview(subjectLabel)
        subjectLabel.font = AppTheme.current.fonts.regular(16)
        subjectLabel.textColor = AppTheme.current.colors.activeElementColor
        subjectLabel.numberOfLines = 2
        
        addSubview(clearButton)
        clearButton.clipsToBounds = true
        clearButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.decorationElementColor), for: .normal)
        clearButton.tintColor = AppTheme.current.colors.inactiveElementColor
        clearButton.setImage(UIImage(named: "cross"), for: .normal) // TODO: make 2 images for both themes and remove background color
        clearButton.adjustsImageWhenHighlighted = false
        clearButton.addTarget(self, action: #selector(onTapToClearButton), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        [titleLabel.leading(16), titleLabel.top(4), titleLabel.trailing(16)].toSuperview()
        [subjectLabel.leading(16), subjectLabel.bottom(4)].toSuperview()
        titleLabel.bottomToTop(-2).to(subjectLabel, addTo: self)
        [clearButton.trailing(8), clearButton.centerY()].toSuperview()
        clearButton.width(36)
        clearButton.height(36)
        subjectLabel.trailingToLeading(4).to(clearButton, addTo: self)
    }
    
    @objc private func onTapToClearButton() {
        onClear?()
    }
    
}
