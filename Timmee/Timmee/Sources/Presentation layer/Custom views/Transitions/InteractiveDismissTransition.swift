//
//  InteractiveDismissTransition.swift
//  Timmee
//
//  Created by i.kharabet on 18.07.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class InteractiveDismissTransition: UIPercentDrivenInteractiveTransition {
        
    var hasStarted: Bool = false
    
    var onClose: (() -> Void)?
    
    private var isCancelled: Bool = false
    private var shouldFinish: Bool = false
    private var isBeingFinished: Bool = false
    
    private var previousContentOffset: CGFloat = 0
    private var currentTranslation: CGFloat = 0
    
    private var isDragging: Bool = false
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDragging = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isBeingFinished else { return }
        
        if !hasStarted, currentTranslation > 0 {
            isCancelled = false
            hasStarted = true
            onClose?()
        }
        if hasStarted, currentTranslation < 0, !isCancelled {
            previousContentOffset = 0
//            currentTranslation = 0
            isCancelled = true
            hasStarted = false
            cancel()
        }
        
        let contentOffsetDifference = -(scrollView.contentOffset.y - previousContentOffset)
        if currentTranslation >= 0 {
            scrollView.contentOffset.y = -scrollView.contentInset.top
        }
        previousContentOffset = scrollView.contentOffset.y
        currentTranslation += contentOffsetDifference
        print("translation \(currentTranslation)")
        
        guard !isCancelled, isDragging else { return }
        
        let progress = max(0, min(1, currentTranslation / scrollView.bounds.height))
        shouldFinish = progress > 0.40
//        print("progress \(progress) translation \(currentTranslation) diff \(contentOffsetDifference)")
        update(progress)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        hasStarted = false
        isDragging = false
        if shouldFinish {
            isBeingFinished = true
            finish()
        } else {
//            if !decelerate {
                previousContentOffset = 0
                currentTranslation = 0
//            }
            isCancelled = true
            cancel()
        }
    }
    
}
