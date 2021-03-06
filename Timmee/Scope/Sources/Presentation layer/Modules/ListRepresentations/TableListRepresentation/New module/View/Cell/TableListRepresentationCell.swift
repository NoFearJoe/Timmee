//
//  TableListRepresentationCell.swift
//  Timmee
//
//  Created by Ilya Kharabet on 16.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

final class TableListRepresentationCell: TableListRepresentationBaseCell {
    
    @IBOutlet private var timeTemplateLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var subtasksLabel: UILabel!
    @IBOutlet private var importancyPicker: TaskImportancyPicker!
    
    @IBOutlet private var tagsView: UIScrollView!
    
    @IBOutlet private var subtitleLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var subtasksLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var tagsViewHeightConstraint: NSLayoutConstraint!
    
    var timeTemplate: String? {
        didSet {
            guard timeTemplate != oldValue || oldValue == nil else { return }
            updateTimeTemplateView(with: timeTemplate)
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
            importancyPicker.isPicked = isImportant
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        importancyPicker.isPicked = false
        importancyPicker.changeStateAutomatically = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.containerView.shouldDrawProgressIndicator = false
        removeModificationAnimations()
    }
    
    override func setTask(_ task: Task) {
        super.setTask(task)
        
        updateTagColors(with:
            task.tags
                .sorted(by: { $0.title < $1.title })
                .map { $0.color }
        )
        
        let hasParameters = task.timeTemplate != nil || task.subtasks.count > 0 || task.dueDate != nil
        maxTitleLinesCount = hasParameters ? 1 : 2
        
        inProgress = task.inProgress
        
        timeTemplate = task.timeTemplate?.title
        
        updateSubtitleLabel(with: makeSubtitleString(task: task))
        
        subtasksInfo = (task.subtasks.filter { $0.isDone }.count, task.subtasks.count)
        
        isImportant = task.isImportant
        
        importancyPicker.onPick = { [unowned self] _ in
            self.onTapToImportancy?()
        }
    }
    
    override func applyAppearance() {
        super.applyAppearance()
        containerView.alpha = 1
        timeTemplateLabel.textColor = AppTheme.current.specialColor
        subtasksLabel.textColor = AppTheme.current.secondaryTintColor
    }
    
    /// Когда задача добавляется или перемещается, должна показываться эта анимация
    func animateModification() {
        removeModificationAnimations()
        
        let fadeIn = CABasicAnimation(keyPath: "backgroundColor")
        fadeIn.fromValue = AppTheme.current.foregroundColor.cgColor
        fadeIn.toValue = AppTheme.current.yellowColor.withAlphaComponent(0.5).cgColor
        fadeIn.duration = 0.1
        fadeIn.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        
        let fadeOut = CABasicAnimation(keyPath: "backgroundColor")
        fadeOut.fromValue = AppTheme.current.yellowColor.withAlphaComponent(0.5).cgColor
        fadeOut.toValue = AppTheme.current.foregroundColor.cgColor
        fadeOut.duration = 3
        fadeOut.beginTime = CACurrentMediaTime() + 0.1
        fadeOut.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        let layerForAnimation = CALayer()
        layerForAnimation.name = "layerForAnimation"
        layerForAnimation.frame = containerView.layer.bounds.insetBy(dx: 0, dy: 2)
        layerForAnimation.cornerRadius = AppTheme.current.cornerRadius
        layerForAnimation.masksToBounds = true
        
        containerView.layer.insertSublayer(layerForAnimation, at: 0)
        
        layerForAnimation.add(fadeIn, forKey: "fadeIn")
        layerForAnimation.add(fadeOut, forKey: "fadeOut")
    }
    
    private func removeModificationAnimations() {
        containerView.layer.sublayers?.first(where: { $0.name == "layerForAnimation" })?.removeFromSuperlayer()
    }
    
}

private extension TableListRepresentationCell {
    
    func updateTimeTemplateView(with timeTemplate: String?) {
        timeTemplateLabel.text = timeTemplate
        if let timeTemplate = timeTemplate, !timeTemplate.isEmpty {
            subtitleLabelLeadingConstraint.constant = 10
        } else {
            subtitleLabelLeadingConstraint.constant = 0
        }
    }
    
    func makeSubtitleString(task: Task) -> NSAttributedString? {
        switch task.kind {
        case .single:
            guard let subtitle = task.dueDate?.asNearestDateString else { return nil }
            let isOverdue = UserProperty.highlightOverdueTasks.bool() && (task.dueDate != nil && !(task.dueDate! >= Date()))
            let subtitleСolor = isOverdue ? AppTheme.current.redColor : AppTheme.current.secondaryTintColor
            return NSAttributedString(string: subtitle, attributes: [.foregroundColor: subtitleСolor])
        case .regular:
            if let endDate = task.repeatEndingDate, endDate.startOfDay.isLower(than: Date().startOfDay) {
                return NSAttributedString(string: "regular_task_finished".localized, attributes: [.foregroundColor: AppTheme.current.redColor])
            }
            
            let repeatingString = task.repeating.fullLocalizedString
            var startDateString = ""
            if let startDate = task.dueDate, startDate.startOfDay.isGreater(than: Date().startOfDay) {
                startDateString = "from_date".localized.lowercased() + " " + startDate.asNearestShortDateString.lowercased()
            }
            var endDateString = ""
            if let endDate = task.repeatEndingDate, endDate.startOfDay.isGreater(than: Date().startOfDay) {
                endDateString = "to_date".localized.lowercased() + " " + endDate.asNearestShortDateString.lowercased()
            }
            let subtitle = [repeatingString, startDateString, endDateString].filter({ !$0.isEmpty }).joined(separator: " ")
            return NSAttributedString(string: subtitle, attributes: [.foregroundColor: AppTheme.current.secondaryTintColor])
        }
    }
    
    func updateSubtitleLabel(with subtitle: NSAttributedString?) {
        subtitleLabel.attributedText = subtitle
        
        if let subtitle = subtitle, !subtitle.string.isEmpty {
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
    
    func updateProgressState(with inProgress: Bool) {
        containerView.shouldDrawProgressIndicator = inProgress
    }
    
}

final class TableListRepersentationCellContainerView: UIView {
    
    var fillColor: UIColor = AppTheme.current.foregroundColor {
        didSet { setNeedsDisplay() }
    }
    
    var shouldDrawProgressIndicator: Bool = false {
        didSet {
            shouldDrawProgressIndicator ? addProgressIndicatorLayer() : removeProgressIndicatorLayer()
        }
    }
    
    private func addProgressIndicatorLayer() {
        let progressIndicatorRect = CGRect(origin: .zero, size: CGSize(width: 3, height: frame.height)).insetBy(dx: 0, dy: 2)
        let layer = CALayer()
        layer.name = "progress_indicator"
        layer.frame = progressIndicatorRect
        layer.backgroundColor = AppTheme.current.blueColor.cgColor
        self.layer.insertSublayer(layer, at: 1)
    }
    
    private func removeProgressIndicatorLayer() {
        layer.sublayers?.first(where: { $0.name == "progress_indicator" })?.removeFromSuperlayer()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            super.draw(rect)
            return
        }
        
        context.setFillColor(fillColor.cgColor)
        
        let path = UIBezierPath(roundedRect: rect.insetBy(dx: 0, dy: 2),
                                cornerRadius: AppTheme.current.cornerRadius)
        path.fill()
        path.addClip()
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
