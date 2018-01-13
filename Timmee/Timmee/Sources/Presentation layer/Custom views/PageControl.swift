//
//  PageControl.swift
//  Test
//
//  Created by i.kharabet on 22.08.17.
//  Copyright © 2017 i.kharabet. All rights reserved.
//

import UIKit

protocol PageControlDelegate: class {
    func pageControl(_ pageControl: PageControl, selectedPageChangedTo page: Int, isPlus: Bool)
}

final class PageControl: UIView {
    
    fileprivate weak var _delegate: PageControlDelegate?
    @IBOutlet var delegate: AnyObject? {
        get { return _delegate }
        set { _delegate = newValue as? PageControlDelegate }
    }
    
    fileprivate var _pagesCount: Int = 0 {
        didSet { update() }
    }
    @IBInspectable var pagesCount: Int {
        get { return _pagesCount }
        set { _pagesCount = min(newValue, maxPagesCount) }
    }
    
    @IBInspectable var pageIndicatorDefaultColor: UIColor = .black {
        didSet { updateAppearance() }
    }
    
    @IBInspectable var pageIndicatorSelectedColor: UIColor = .black {
        didSet { updateAppearance() }
    }
    
    fileprivate var _selectedPage: Int = 0 {
        didSet {
            updateSelectedPage()
            updateScrollPosition(oldSelectedPage: oldValue)
        }
    }
    @IBInspectable var selectedPage: Int {
        get { return _selectedPage }
        set { _selectedPage = min(newValue, maxPagesCount) }
    }
    
    @IBInspectable var pageIndicatorSize: CGFloat  = 8 {
        didSet { update() }
    }
    
    @IBInspectable var interitemSpacing: CGFloat = 12 {
        didSet { update() }
    }
    
    fileprivate var contentWidth: CGFloat {
        let fullWidth = CGFloat(pagesCount + 1) * pageIndicatorSize + CGFloat(pagesCount) * interitemSpacing
        return min(fullWidth, frame.width)
    }
    
    fileprivate var maxPagesCount: Int {
        return Int(floor((frame.width - interitemSpacing) / (pageIndicatorSize + interitemSpacing)))
    }
    
    fileprivate var shouldDrawPlus: Bool {
        return pagesCount != maxPagesCount
    }
    
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    @IBOutlet fileprivate weak var containerView: UIView!
    
    @IBInspectable var fontSize: CGFloat = 10
    @IBInspectable var maxWidth: CGFloat = 96
    
    var titles: [String] = [] {
        didSet {
            update()
        }
    }
    fileprivate var titleLabels: [UILabel] = []
    
    func update() {
        removeAllLabels()
        (0...pagesCount).forEach { page in
            let label: UILabel
            if shouldDrawPlus && page == pagesCount {
                label = self.createLabel(title: "new_list".localized, index: page)
            } else {
                label = self.createLabel(title: titles.item(at: page) ?? "", index: page)
            }
            
            if page == selectedPage {
                label.textColor = pageIndicatorSelectedColor
            } else {
                label.textColor = pageIndicatorDefaultColor
            }
            
            self.containerView?.addSubview(label)
            self.titleLabels.append(label)
            
            if pagesCount == 0 {
                layoutLabel(label, after: nil, isLast: true)
            } else if pagesCount > 0 {
                if page == 0 {
                    layoutLabel(label, after: nil)
                } else if page == pagesCount {
                    layoutLabel(label, after: self.titleLabels.item(at: page - 1), isLast: true)
                } else {
                    layoutLabel(label, after: self.titleLabels.item(at: page - 1))
                }
            }
        }
    }
    
    func updateSelectedPage() {
        updateAppearance()
    }
    
    func updateAppearance() {
        for (index, label) in titleLabels.enumerated() {
            if index == selectedPage {
                label.textColor = pageIndicatorSelectedColor
            } else {
                label.textColor = pageIndicatorDefaultColor
            }
        }
    }
    
    fileprivate func updateScrollPosition(oldSelectedPage: Int) {
        if oldSelectedPage > selectedPage,
            let selectedLabel = titleLabels.item(at: selectedPage - 1) ?? titleLabels.item(at: selectedPage) {
            
            let offsetX = scrollView.contentOffset.x
            let frame = selectedLabel.frame.offsetBy(dx: 21, dy: 0)
            if offsetX > frame.origin.x && offsetX <= frame.origin.x + frame.width {
                let targetOffset = CGPoint(x: frame.origin.x - 21, y: 0)
                scrollView.setContentOffset(targetOffset, animated: true)
            }
        } else if oldSelectedPage < selectedPage,
            let selectedLabel = titleLabels.item(at: selectedPage + 1) ?? titleLabels.item(at: selectedPage) {
            
            let offsetX = scrollView.contentOffset.x + bounds.width - 21
            let frame = selectedLabel.frame.offsetBy(dx: 21, dy: 0)
            if offsetX >= frame.origin.x && offsetX < frame.origin.x + frame.width {
                let targetOffset = CGPoint(x: abs(offsetX - (frame.origin.x + frame.width)), y: 0)
                scrollView.setContentOffset(targetOffset, animated: true)
            }
        }
    }
    
    fileprivate func createLabel(title: String, index: Int) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: fontSize, weight: UIFont.Weight.regular)
        label.tag = index
        label.isUserInteractionEnabled = true
        label.lineBreakMode = .byClipping
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PageControl.onLabelTap(recognizer:)))
        label.addGestureRecognizer(tapGestureRecognizer)
        
        return label
    }
    
    fileprivate func removeAllLabels() {
        containerView?.subviews.forEach {
            if $0.superview != nil {
                $0.removeFromSuperview()
            }
        }
        titleLabels = []
    }
    
    fileprivate func layoutLabel(_ label: UILabel, after leftLabel: UILabel?, isLast: Bool = false) {
        guard label.superview != nil else { return }
        
        [label.top(), label.bottom()].toSuperview()
        label.width(lessOrEqual: maxWidth)
        
        if let leftLabel = leftLabel {
            label.leadingToTrailing(interitemSpacing).to(leftLabel)
        } else {
            label.leading().toSuperview()
        }
        
        if isLast {
            label.trailing().toSuperview()
        }
    }
    
    
    @objc func onLabelTap(recognizer: UITapGestureRecognizer) {
        guard let label = recognizer.view as? UILabel else { return }
        
        let tappedPageIndicatorIndex = titleLabels.index(of: label) ?? label.tag
        let limitedPageIndicatorIndex = min(tappedPageIndicatorIndex, pagesCount)
        
        selectedPage = limitedPageIndicatorIndex
        
        let isPlus = shouldDrawPlus ? selectedPage == pagesCount : false
        _delegate?.pageControl(self, selectedPageChangedTo: selectedPage, isPlus: isPlus)
    }
    
}
