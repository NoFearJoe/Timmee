//
//  InteractiveDismissTransition.swift
//  Timmee
//
//  Created by i.kharabet on 18.07.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class InteractiveDismissTransition: UIPercentDrivenInteractiveTransition {
    
    weak var viewController: UIViewController?
    
    var hasStarted: Bool = false
    
    var onClose: (() -> Void)?
    
    private var shouldFinish: Bool = false
    private var isBeingFinished: Bool = false
    
    private var previousContentOffset: CGFloat = 0
    private var currentTranslation: CGFloat = 0
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {}
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isBeingFinished else { return }
        
        if !hasStarted {
            hasStarted = true
            onClose?()
        }
        
        let contentOffsetDifference = -(scrollView.contentOffset.y - previousContentOffset)
        if currentTranslation > 0 {
            scrollView.contentOffset.y = -scrollView.contentInset.top
        }
        previousContentOffset = scrollView.contentOffset.y
        currentTranslation += contentOffsetDifference
        
        let progress = max(0, min(1, currentTranslation / scrollView.bounds.height))
        shouldFinish = progress > 0.33
        print("progress \(progress) translation \(currentTranslation) diff \(contentOffsetDifference)")
        update(progress)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        hasStarted = false
        if shouldFinish {
            finish()
            print("finished")
            isBeingFinished = true
        } else {
            previousContentOffset = 0
            currentTranslation = 0
            print("cancelled")
            cancel()
        }
    }
    
}
