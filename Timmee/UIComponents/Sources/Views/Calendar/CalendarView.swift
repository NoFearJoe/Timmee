//
//  CalendarView.swift
//  UIComponents
//
//  Created by i.kharabet on 27/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

public final class CalendarView: UIView {
    
    var onChangeHeight: ((CGFloat) -> Void)?
    
    private typealias SectionView = UIView & CalendarSectionView
    
    private let state = CalendarState()
    
    private var sectionViews: [SectionView] = []
    private var currentSectionView: SectionView? {
        return sectionViews.last
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public func configure(selectedDate: Date?, currentDate: Date, minimumDate: Date?, section: CalendarSection = .days) {
        state.selectedDate = selectedDate
        state.currentDate = currentDate
        state.minimumDate = minimumDate
        state.section = section
        
        setSectionView(section: section)
    }
    
    public func reload() {
        currentSectionView?.reload()
    }
    
}

private extension CalendarView {
    
    func setSectionView(section: CalendarSection) {
        let view = getSectionView(for: section)
        addSubview(view)
        view.allEdges().toSuperview()
        
        setupSectionView(view, for: section)
        
        sectionViews.append(view)
    }
    
    private func getSectionView(for section: CalendarSection) -> SectionView {
        switch section {
        case .days: return CalendarDaysView(state: state)
        case .months: return CalendarMonthsView(state: state)
        case .years: return CalendarDaysView(state: state)
        }
    }
    
    private func setupSectionView(_ view: SectionView, for section: CalendarSection) {
        view.onChangeHeight = { [unowned self] height in
            self.onChangeHeight?(height)
        }
        view.onChangeSection = { [unowned self] section in
            guard section != self.state.section else { return }
            if section.rawValue > self.state.section.rawValue {
                let sectionView = self.getSectionView(for: section)
                self.setupSectionView(sectionView, for: section)
                self.pushSectionView(sectionView, completion: { sectionView in
                    sectionView.triggerHeightUpdate()
                    sectionView.reload()
                })
            } else {
                self.popViewController()
            }
            self.state.section = section
        }
    }
    
    private func pushSectionView(_ view: SectionView, completion: @escaping (SectionView) -> Void) {
        let offset = bounds.height
        
        if let fromView = subviews.first as? SectionView {
            addSubview(view)
            view.allEdges().toSuperview()
            view.transform = CGAffineTransform(translationX: 0, y: offset)
            
            completion(view)
            fromView.setHeightUpdatesSuspended(true)
            
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: .curveEaseOut,
                           animations: {
                            fromView.transform = CGAffineTransform(translationX: 0, y: -offset)
                            view.transform = .identity
            }, completion: { _ in
                fromView.removeFromSuperview()
                self.sectionViews.append(view)
            })
        }
    }
    
    private func popViewController() {
        guard let fromView = sectionViews.last else { return }
        guard let toView = sectionViews.item(at: sectionViews.count - 2) else { return }
        
        let offset = bounds.height
        
        addSubview(toView)
        toView.allEdges().toSuperview()
        toView.transform = CGAffineTransform(translationX: 0, y: -offset)
        
        toView.triggerHeightUpdate()
        fromView.setHeightUpdatesSuspended(true)
        
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: {
                        toView.transform = .identity
                        fromView.transform = CGAffineTransform(translationX: 0, y: offset)
        }, completion: { _ in
            toView.allEdges().toSuperview()
            fromView.removeFromSuperview()
            self.sectionViews.removeLast()
        })
    }
    
}
