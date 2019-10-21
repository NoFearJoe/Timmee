//
//  CalendarViewController.swift
//  UIComponents
//
//  Created by i.kharabet on 27/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import Workset

public final class CalendarViewController: UIPageViewController {
    
    public var onSelectDate: ((Date?) -> Void)?
    public var badgeValue: ((Date) -> String?)?
    
    public var maximumHeight: CGFloat {
        return currentPage?.maximumHeight ?? 0
    }
    
    private var currentPage: CalendarPage? {
        return viewControllers?.first as? CalendarPage
    }
    
    private var selectedDate: Date?
    private var currentDate: Date = Date()
    private var minimumDate: Date = Date()
    private var maximumDate: Date?
    
    private let design: CalendarDesign
    
    public init(design: CalendarDesign) {
        self.design = design
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
        
        setupFirstPage()
    }
    
    private var isConfigured: Bool = false
    
    public func configure(selectedDate: Date?, minimumDate: Date?, maximumDate: Date? = nil) {
        isConfigured = true
        
        self.selectedDate = selectedDate
        if #available(iOSApplicationExtension 10.0, *) {
            self.currentDate = selectedDate?.startOfMonth() ?? Date().startOfMonth() ?? Date().startOfMonth
        } else {
            self.currentDate = selectedDate?.startOfMonth ?? Date().startOfMonth
        }
        self.minimumDate = minimumDate ?? Date(timeIntervalSince1970: 0)
        self.maximumDate = maximumDate
        
        setupFirstPage()
    }
    
    private func createPage(state: CalendarState) -> CalendarPage {
        let page = CalendarPage(state: state, design: design)
        
        page.onSelectDate = { [unowned self] date in
            self.selectedDate = date
            self.onSelectDate?(date)
        }
        page.badgeValue = { [unowned self] date in
            return self.badgeValue?(date)
        }
        
        return page
    }
    
    private func setupFirstPage() {
        guard isConfigured else { return }
        
        let state = CalendarState(currentDate: currentDate,
                                  minimumDate: minimumDate,
                                  maximumDate: maximumDate,
                                  selectedDate: selectedDate)
        let page = createPage(state: state)
        
        setViewControllers([page],
                           direction: .forward,
                           animated: false,
                           completion: nil)
        
        page.reload()
    }
    
}

extension CalendarViewController: UIPageViewControllerDataSource {
    
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentPage = viewController as? CalendarPage else { return nil }
        let currentDate = currentPage.state.currentDate
        let nextDate = currentDate + 1.asMonths
        let nextState = CalendarState(currentDate: nextDate,
                                      minimumDate: minimumDate,
                                      maximumDate: maximumDate,
                                      selectedDate: selectedDate)
        let nextPage = createPage(state: nextState)
        nextPage.reload()
        return nextPage
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentPage = viewController as? CalendarPage else { return nil }
        let currentDate = currentPage.state.currentDate
        let previousDate = currentDate - 1.asMonths
        let previousState = CalendarState(currentDate: previousDate,
                                          minimumDate: minimumDate,
                                          maximumDate: maximumDate,
                                          selectedDate: selectedDate)
        let previousPage = createPage(state: previousState)
        previousPage.reload()
        return previousPage
    }
    
}

extension CalendarViewController: UIPageViewControllerDelegate {
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let pages = pendingViewControllers as? [CalendarPage] else { return }
        pages.forEach { page in
            page.state.selectedDate = selectedDate
            page.reload()
        }
    }
    
}
