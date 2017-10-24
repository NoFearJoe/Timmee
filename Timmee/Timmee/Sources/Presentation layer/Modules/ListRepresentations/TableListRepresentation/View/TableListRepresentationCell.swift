//
//  TableListRepresentationCell.swift
//  Timmee
//
//  Created by Ilya Kharabet on 16.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

final class TableListRepresentationCell: SwipeTableViewCell {
    
    @IBOutlet fileprivate weak var containerView: TableListRepersentationCellContainerView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var dueDateLabel: UILabel!
    @IBOutlet fileprivate weak var subtasksLabel: UILabel!
    @IBOutlet fileprivate weak var importancyContainerView: UIView!
    @IBOutlet fileprivate weak var importancyIconView: UIImageView!
    @IBOutlet fileprivate weak var attachmentsIconView: UIImageView!
    
    @IBOutlet fileprivate weak var tagsView: UIScrollView!
    
    @IBOutlet fileprivate weak var subtasksLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var attachmentsViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet fileprivate weak var tagsViewHeightConstraint: NSLayoutConstraint!
    
    var title: String? {
        get { return titleLabel.attributedText?.string }
        set {
            guard let title = newValue else { return }
            updateTitle(title)
        }
    }
    
    var dueDate: String? {
        didSet {
            dueDateLabel.text = dueDate
            if let dueDate = dueDate, !dueDate.isEmpty {
                subtasksLabelLeadingConstraint.constant = 10
            } else {
                subtasksLabelLeadingConstraint.constant = 0
            }
            updateAttachmentsViewLeadingConstraint()
        }
    }
    
    var subtasksInfo: (done: Int, total: Int)? {
        didSet {
            if let info = subtasksInfo, info.total != 0 {
                subtasksLabel.text = "\(info.done)/\(info.total) подзадач" // TODO: убрать подзадач? поставить иконку???
            } else {
                subtasksLabel.text = nil
            }
            updateAttachmentsViewLeadingConstraint()
        }
    }
    
    func updateAttachmentsViewLeadingConstraint() {
        if dueDate == nil && subtasksInfo == nil {
            attachmentsViewLeadingConstraint.constant = 0
        } else {
            attachmentsViewLeadingConstraint.constant = 10
        }
    }
    
    var isImportant: Bool = false {
        didSet {
            importancyIconView.alpha = isImportant ? 1 : 0.5
        }
    }
    
    var containsAttachments: Bool = false {
        didSet {
            attachmentsIconView.isHidden = !containsAttachments // TODO
        }
    }
    
    var isDone: Bool = false {
        didSet {
            containerView.alpha = isDone ? 0.75 : 1
            
            guard let title = title else { return }
            updateTitle(title)
        }
    }
    
    func updateTagColors(with colors: [UIColor]) {
        tagsView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        
        let spacing: CGFloat = 6
        let size: CGFloat = 6
        let tagViews = colors.map { SmallTagView(frame: CGRect(x: 0, y: 0,
                                                               width: size, height: size),
                                                 color: $0) }
        for (index, view) in tagViews.enumerated() {
            view.frame.origin.x = CGFloat(index) * size + CGFloat(index) * spacing
            tagsView.addSubview(view)
        }
        
        tagsViewHeightConstraint.constant = colors.count > 0 ? 6 : 0
    }
    
    var maxTitleLinesCount: Int = 1 {
        didSet {
            titleLabel.numberOfLines = maxTitleLinesCount // FIXME: Bug - иногда отображается одна линия
        }
    }
    
    var onTapToImportancy: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.fillColor = AppTheme.current.scheme.cellBackgroundColor
        titleLabel.textColor = AppTheme.current.scheme.cellTintColor
        addTapToImportancyGestureRecognizer()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        containerView.setNeedsDisplay()
        
        isImportant = false
        containsAttachments = false
        isDone = false
        
        maxTitleLinesCount = 1
    }
    
    
    fileprivate func updateTitle(_ title: String) {
        titleLabel.text = title
    }
    
    fileprivate func addTapToImportancyGestureRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapImportancyView))
        importancyContainerView.addGestureRecognizer(recognizer)
    }
    
    @objc fileprivate func tapImportancyView() {
        onTapToImportancy?()
    }
    
}

final class TableListRepersentationCellContainerView: UIView {
    
    var fillColor: UIColor = AppTheme.current.scheme.cellBackgroundColor
    var cornerRadius: CGFloat = 4
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            super.draw(rect)
            return
        }
        
        context.setFillColor(fillColor.cgColor)
        
        let path = UIBezierPath(roundedRect: rect.insetBy(dx: 0, dy: 1),
                                cornerRadius: cornerRadius)
        path.fill()
    }
    
}

final class SmallTagView: UIView {
    
    convenience init(frame: CGRect, color: UIColor) {
        self.init(frame: frame)
        backgroundColor = color
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.width * 0.5
    }
    
}
