//
//  GrowingTextView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 03.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

@objc protocol GrowingTextViewDelegate: UITextViewDelegate {
    @objc optional func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat)
}

@IBDesignable @objc
open class GrowingTextView: UITextView {
    override open var text: String! {
        didSet { setNeedsDisplay() }
    }
    private weak var heightConstraint: NSLayoutConstraint?
    
    // Maximum length of text. 0 means no limit.
    @IBInspectable open var maxLength: Int = 0
    
    // Trim white space and newline characters when end editing. Default is true
    @IBInspectable open var trimWhiteSpaceWhenEndEditing: Bool = true
    
    // Customization
    @IBInspectable open var minHeight: CGFloat = 0 {
        didSet { forceLayoutSubviews() }
    }
    @IBInspectable open var maxHeight: CGFloat = 0 {
        didSet { forceLayoutSubviews() }
    }
    @IBInspectable open var placeHolder: String? {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable open var placeHolderColor: UIColor = UIColor(white: 0.8, alpha: 1.0) {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable open var attributedPlaceHolder: NSAttributedString? {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable open var placeHolderLeftMargin: CGFloat = 5 {
        didSet { setNeedsDisplay() }
    }
    
    // Initialize
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        contentMode = .redraw
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
        associateConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: .UITextViewTextDidChange, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidEndEditing), name: .UITextViewTextDidEndEditing, object: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 30)
    }
    
    func associateConstraints() {
        // iterate through all text view's constraints and identify
        // height,from: https://github.com/legranddamien/MBAutoGrowingTextView
        for constraint in constraints {
            if (constraint.firstAttribute == .height) {
                if (constraint.relation == .equal) {
                    heightConstraint = constraint;
                }
            }
        }
    }
    
    // Calculate and adjust textview's height
    private var oldText: String = ""
    private var oldSize: CGSize = .zero
    
    private func forceLayoutSubviews() {
        oldSize = .zero
        setNeedsLayout()
        layoutIfNeeded()
    }
        
    override open func layoutSubviews() {
        let heightChanged = heightWillChanged()
        if heightChanged { saveContentOffset() }
        
        super.layoutSubviews()
        layout()
        
        if heightChanged { saveContentOffset() }
    }
    
    private func saveContentOffset() {
        if contentOffset != correctContentOffset && !isDragging && !isDecelerating {
            contentOffset = correctContentOffset
        }
    }
    
    private func calculateTargetHeight() -> CGFloat {
        let size = sizeThatFits(CGSize(width: bounds.size.width,
                                       height: CGFloat.greatestFiniteMagnitude))
        
        var height = size.height
        
        // Constrain minimum height
        height = minHeight > 0 ? max(height, minHeight) : height
        
        // Constrain maximum height
        height = maxHeight > 0 ? min(height, maxHeight) : height
        
        return height
    }
    
    private func heightWillChanged() -> Bool {
        return calculateTargetHeight() != oldSize.height
    }
    
    private func layout() {
        if text == oldText && bounds.size == oldSize { return }
        oldText = text
        oldSize = bounds.size
        
        let height = calculateTargetHeight()
        
        // Add height constraint if it is not found
        if (heightConstraint == nil) {
            heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height)
            addConstraint(heightConstraint!)
        }
        
        // Update height constraint if needed
        if height != heightConstraint?.constant {
            heightConstraint!.constant = height
            
            if let delegate = delegate as? GrowingTextViewDelegate {
                delegate.textViewDidChangeHeight?(self, height: height)
            }
        }
        
        if height != oldSize.height {
            scrollToCorrectPosition()
        }
    }
    
    private func scrollToCorrectPosition() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            if self.isFirstResponder {
                self.contentOffset = self.correctContentOffset
            } else {
                self.contentOffset = .zero
            }
        }
    }
    
    // Show placeholder if needed
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        if text.isEmpty {
            let xValue = textContainerInset.left + placeHolderLeftMargin
            let yValue = textContainerInset.top
            let width = rect.size.width - xValue - textContainerInset.right
            let height = rect.size.height - yValue - textContainerInset.bottom
            let placeHolderRect = CGRect(x: xValue, y: yValue, width: width, height: height)
            
            if let attributedPlaceholder = attributedPlaceHolder {
                // Prefer to use attributedPlaceHolder
                attributedPlaceholder.draw(in: placeHolderRect)
            } else if let placeHolder = placeHolder {
                // Otherwise user placeHolder and inherit `text` attributes
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = textAlignment
                var attributes: [String: Any] = [
                    NSForegroundColorAttributeName: placeHolderColor,
                    NSParagraphStyleAttributeName: paragraphStyle
                ]
                if let font = font {
                    attributes[NSFontAttributeName] = font
                }
                
                placeHolder.draw(in: placeHolderRect, withAttributes: attributes)
            }
        }
    }
    
    // Trim white space and new line characters when end editing.
    func textDidEndEditing(notification: Notification) {
        if let notificationObject = notification.object as? GrowingTextView {
            if notificationObject === self {
                if trimWhiteSpaceWhenEndEditing {
                    text = text?.trimmingCharacters(in: .whitespacesAndNewlines)
                    setNeedsDisplay()
                }
            }
            scrollToCorrectPosition()
        }
    }
    
    // Limit the length of text
    func textDidChange(notification: Notification) {
        if let notificationObject = notification.object as? GrowingTextView {
            if notificationObject === self {
                if maxLength > 0 && text.characters.count > maxLength {
                    
                    let endIndex = text.index(text.startIndex, offsetBy: maxLength)
                    text = text.substring(to: endIndex)
                    undoManager?.removeAllActions()
                }
                self.setNeedsDisplay()
            }
        }
    }
    
    private var correctContentOffset: CGPoint {
        let constraintHeight = (self.heightConstraint?.constant ?? 0)
        if constraintHeight < maxHeight {
            return .zero
        }
        let y = contentSize.height - constraintHeight
        let roundedY = floor(y)
        return CGPoint(x: 0, y: max(0, roundedY))
    }
}
