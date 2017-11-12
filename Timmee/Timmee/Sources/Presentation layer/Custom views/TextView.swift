//
//  TextView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 11.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

class TextView: UITextView {

    override open var text: String! {
        didSet { setNeedsDisplay() }
    }
    
//    override var contentSize: CGSize {
//        didSet {
//            if oldValue.height != contentSize.height {
//                onChangeContentHeight?(contentSize.height)
//            }
//        }
//    }
    
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
    
    var onChangeContentHeight: ((CGFloat) -> Void)?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        contentMode = .redraw
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: .UITextViewTextDidChange, object: self)
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        if text.isEmpty {
            let xValue = textContainerInset.left + placeHolderLeftMargin
            let yValue = textContainerInset.top
            let width = rect.size.width - xValue - textContainerInset.right
            let height = rect.size.height - yValue - textContainerInset.bottom
            let placeHolderRect = CGRect(x: xValue, y: yValue, width: width, height: height)
            
            if let attributedPlaceholder = attributedPlaceHolder {
                attributedPlaceholder.draw(in: placeHolderRect)
            } else if let placeHolder = placeHolder {
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
    
    func textDidChange(notification: Notification) {
        let maxWidth = self.frame.width
        let textRect = (text as NSString).boundingRect(with: CGSize(width: maxWidth, height: 99999),
                                                       options: .usesLineFragmentOrigin,
                                                       attributes: [NSFontAttributeName: self.font!],
                                                       context: nil)
        if textRect.height > self.frame.height {
            onChangeContentHeight?(textRect.height)
        }
        setNeedsDisplay()
    }

}
