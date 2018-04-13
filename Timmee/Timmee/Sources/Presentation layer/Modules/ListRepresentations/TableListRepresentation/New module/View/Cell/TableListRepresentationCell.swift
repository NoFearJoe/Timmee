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
    
    @IBOutlet private var containerView: TableListRepersentationCellContainerView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var timeTemplateLabel: UILabel!
    @IBOutlet private var dueDateLabel: UILabel!
    @IBOutlet private var subtasksLabel: UILabel!
    @IBOutlet private var importancyContainerView: UIView!
    @IBOutlet private var importancyIconView: UIImageView!
    
    @IBOutlet private var tagsView: UIScrollView!
    
    @IBOutlet private var checkBox: CheckBox! {
        didSet {
            checkBox.didChangeCkeckedState = { [unowned self] isChecked in
                self.onCheck?(isChecked)
            }
        }
    }
    
    @IBOutlet private var dueDateLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var subtasksLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var tagsViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private var containerViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var containerViewTrailingConstraint: NSLayoutConstraint!
    
    var title: String? {
        get { return titleLabel.attributedText?.string }
        set {
            guard let title = newValue else { return }
            updateTitle(title)
        }
    }
    
    var timeTemplate: String? {
        didSet {
            guard timeTemplate != oldValue || oldValue == nil else { return }
            updateTimeTemplateView(with: timeTemplate)
        }
    }
    
    var dueDate: Date? {
        didSet {
            let isOverdue = UserProperty.highlightOverdueTasks.bool() && (dueDate != nil && !(dueDate! >= Date()))
            updateDueDateView(with: dueDate?.asNearestDateString, isOverdue: isOverdue)
        }
    }
    
    var subtasksInfo: (done: Int, total: Int)? {
        didSet {
            if let subtasksInfo = subtasksInfo, let oldValue = oldValue {
                if subtasksInfo.done == oldValue.done,
                    subtasksInfo.total == oldValue.total { return }
            }
            updateSubtasksView(with: subtasksInfo)
        }
    }
    
    var isImportant: Bool = false {
        didSet {
            guard isImportant != oldValue else { return }
            importancyIconView.image = isImportant ? #imageLiteral(resourceName: "important_active") : #imageLiteral(resourceName: "important_inactive")
        }
    }
    
    var isDone: Bool = false {
        didSet {
            guard isDone != oldValue else { return }
            updateDoneState(with: isDone)
        }
    }
    
    var inProgress: Bool = false {
        didSet {
            updateProgressState(with: inProgress)
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
            guard maxTitleLinesCount != oldValue else { return }
            titleLabel.numberOfLines = maxTitleLinesCount
        }
    }
    
    var onTapToImportancy: (() -> Void)?
    
    private var _isGroupEditing: Bool = false
    func setGroupEditing(_ isGroupEditing: Bool,
                         animated: Bool = false,
                         completion: (() -> Void)? = nil) {
        guard isGroupEditing != _isGroupEditing else { return }
        
        _isGroupEditing = isGroupEditing
        
        containerView.isUserInteractionEnabled = !isGroupEditing
        
        containerViewLeadingConstraint.constant = isGroupEditing ? 44 : 8
        containerViewTrailingConstraint.constant = isGroupEditing ? -28 : 8
        
        if animated {
            if isGroupEditing {
                checkBox.isHidden = false
            }
            
            UIView.animate(withDuration: 0.33, animations: {
                self.contentView.layoutIfNeeded()
            }) { finished in
                if finished && !isGroupEditing {
                    self.checkBox.isHidden = true
                }
                completion?()
            }
        } else {
            checkBox.isHidden = !isGroupEditing
            contentView.layoutIfNeeded()
            completion?()
        }
    }
    
    var isChecked: Bool = false {
        didSet {
            checkBox.isChecked = isChecked
        }
    }
    
    
    var onCheck: ((Bool) -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyAppearance()
        checkBox.isHidden = true
        importancyIconView.image = #imageLiteral(resourceName: "important_inactive")
        addTapToImportancyGestureRecognizer()
    }
    
    func setTask(_ task: Task) {
        updateTagColors(with:
            task.tags
                .sorted(by: { $0.title < $1.title })
                .map { $0.color }
        )
        
        let hasParameters = task.timeTemplate != nil || task.subtasks.count > 0 || task.dueDate != nil
        maxTitleLinesCount = hasParameters || task.isDone ? 1 : 2
        
        title = task.title
        
        isDone = task.isDone
        
        inProgress = task.inProgress
        
        if !task.isDone {
            timeTemplate = task.timeTemplate?.title
            dueDate = task.dueDate
            subtasksInfo = (task.subtasks.filter { $0.isDone }.count, task.subtasks.count)
        } else {
            timeTemplate = nil
            dueDate = nil
            subtasksInfo = nil
        }
        
        isImportant = task.isImportant
    }
    
    func applyAppearance() {
        contentView.backgroundColor = .clear
        containerView.fillColor = AppTheme.current.foregroundColor
        titleLabel.textColor = AppTheme.current.tintColor
        timeTemplateLabel.textColor = AppTheme.current.specialColor
        subtasksLabel.textColor = AppTheme.current.secondaryTintColor
    }
    
}

fileprivate extension TableListRepresentationCell {
    
    func updateTimeTemplateView(with timeTemplate: String?) {
        timeTemplateLabel.text = timeTemplate
        if let timeTemplate = timeTemplate, !timeTemplate.isEmpty {
            dueDateLabelLeadingConstraint.constant = 10
        } else {
            dueDateLabelLeadingConstraint.constant = 0
        }
    }
    
    func updateDueDateView(with dueDate: String?, isOverdue: Bool = false) {
        dueDateLabel.text = dueDate
        
        dueDateLabel.textColor = isOverdue ? AppTheme.current.redColor : AppTheme.current.secondaryTintColor
        
        if let dueDate = dueDate, !dueDate.isEmpty {
            subtasksLabelLeadingConstraint.constant = 10
        } else {
            subtasksLabelLeadingConstraint.constant = 0
        }
    }
    
    func updateSubtasksView(with subtasksInfo: (done: Int, total: Int)?) {
        if let info = subtasksInfo, info.total != 0 {
            subtasksLabel.text = "\(info.done) \("of".localized) \(info.total) \("subtasks".localized)"
        } else {
            subtasksLabel.text = nil
        }
    }
    
    func updateDoneState(with isDone: Bool) {
        containerView.alpha = isDone ? 0.75 : 1
        
        guard let title = title else { return }
        updateTitle(title)
    }
    
    func updateProgressState(with inProgress: Bool) {
        containerView.shouldDrawProgressIndicator = inProgress
    }
    
    func updateTitle(_ title: String) {
        titleLabel.text = title
    }
    
    // TODO: Перенести в storyboard
    func addTapToImportancyGestureRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapImportancyView))
        importancyContainerView.addGestureRecognizer(recognizer)
    }
    
    @objc func tapImportancyView() {
        onTapToImportancy?()
    }
    
}

final class TableListRepersentationCellContainerView: UIView {
    
    var fillColor: UIColor = AppTheme.current.foregroundColor
    var cornerRadius: CGFloat = 4
    
    var shouldDrawProgressIndicator: Bool = false {
        didSet { setNeedsDisplay() }
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            super.draw(rect)
            return
        }
        
        context.setFillColor(fillColor.cgColor)
        
        let path = UIBezierPath(roundedRect: rect.insetBy(dx: 0, dy: 2),
                                cornerRadius: cornerRadius)
        path.fill()
        path.addClip()
        
        if shouldDrawProgressIndicator {
            context.setFillColor(AppTheme.current.blueColor.cgColor)
            let indicatorRect = CGRect(x: 0, y: 0, width: 2, height: rect.height)
            context.fill(indicatorRect)
        }
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
