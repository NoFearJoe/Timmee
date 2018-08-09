//
//  InteractiveDismissTransition.swift
//  Timmee
//
//  Created by i.kharabet on 18.07.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

public final class InteractiveDismissTransition: UIPercentDrivenInteractiveTransition {
        
    public var hasStarted: Bool = false
    
    public var onClose: (() -> Void)?
    
    private var isCancelled: Bool = false
    private var shouldFinish: Bool = false
    private var isBeingFinished: Bool = false
    
    private var previousContentOffset: CGFloat = 0
    private var currentTranslation: CGFloat = 0
    
    private var isDragging: Bool = false
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDragging = true
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isBeingFinished else { return }
        
        if !hasStarted, isDragging, currentTranslation > 0, scrollView.contentOffset.y <= 0 {
            isCancelled = false
            hasStarted = true
            onClose?()
        }
        if hasStarted, currentTranslation < 0, !isCancelled {
            isCancelled = true
            hasStarted = false
            cancel()
        }
        
        let contentOffsetDifference = -(scrollView.contentOffset.y - previousContentOffset)
        if currentTranslation + contentOffsetDifference >= 0 {
            scrollView.contentOffset.y = -scrollView.contentInset.top
        }
        previousContentOffset = scrollView.contentOffset.y
        currentTranslation += contentOffsetDifference
        
        guard !isCancelled, isDragging else { return }
        
        let progress = max(0, min(1, currentTranslation / scrollView.bounds.height))
        shouldFinish = progress > 0.4
        update(progress)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isDragging = false
        guard !decelerate else { return }
        hasStarted = false
        if shouldFinish {
            isBeingFinished = true
            finish()
        } else {
            previousContentOffset = 0
            currentTranslation = 0
            isCancelled = true
            cancel()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        hasStarted = false
        isDragging = false
        if shouldFinish {
            isBeingFinished = true
            finish()
        } else {
            previousContentOffset = 0
            currentTranslation = 0
            isCancelled = true
            cancel()
        }
    }
    
}
