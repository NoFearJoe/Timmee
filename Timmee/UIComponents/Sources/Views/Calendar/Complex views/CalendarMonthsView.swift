//
//  CalendarMonthsView.swift
//  UIComponents
//
//  Created by i.kharabet on 27/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import Workset

final class CalendarMonthsView: UIView, CalendarSectionView {
    
    var onChangeHeight: ((CGFloat) -> Void)?
    var onChangeSection: ((CalendarSection) -> Void)?
    
    private let dateComponentsView = CalendarMonthsDateComponentsView()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private let adapter = CalendarMonthsViewAdapter()
    
    private var collectionViewContentSizeObservation: NSKeyValueObservation!
    private var isHeightUpdatesSuspended: Bool = false
    
    private var state: CalendarState
    
    convenience init(state: CalendarState) {
        self.init(frame: .zero)
        self.state = state
    }
    
    private override init(frame: CGRect) {
        state = CalendarState()
        super.init(frame: frame)
        
        setupDateComponentsView()
        setupCollectionView()
        setupConstraints()
        
        collectionViewContentSizeObservation = collectionView.observe(\UICollectionView.contentSize, options: .new) { [unowned self] collectionView, change in
            guard !self.isHeightUpdatesSuspended else { return }
            self.onChangeHeight?(52 + (change.newValue?.height ?? 0) + collectionView.contentInset.top + collectionView.contentInset.bottom)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func reload() {
        let startOfYearDate: Date?
        if #available(iOSApplicationExtension 10.0, *) {
            startOfYearDate = (self.state.currentDate ?? self.state.selectedDate)?.startOfYear()
        } else {
            startOfYearDate = (self.state.currentDate ?? self.state.selectedDate)?.startOfYear
        }
        guard let startOfYear = startOfYearDate else { return }
        
        dateComponentsView.configure(date: startOfYear)
        
        adapter.months = (0..<12).map { month in
            let currentDate = startOfYear + month.asMonths
            return CalendarMonthEntity(title: currentDate.asString(format: "MMM"),
                                       isSelected: self.state.selectedDate?.month == currentDate.month,
                                       isCurrent: currentDate.month == Date().month,
                                       isDisabled: self.state.minimumDate.map { currentDate.month < $0.month } ?? false,
                                       tasksCount: 0)
        }
        collectionView.reloadData()
    }
    
    func triggerHeightUpdate() {
        self.onChangeHeight?(52 + collectionView.contentSize.height + collectionView.contentInset.top + collectionView.contentInset.bottom)
    }
    
    func setHeightUpdatesSuspended(_ isSuspended: Bool) {
        isHeightUpdatesSuspended = isSuspended
    }
    
    private func setupDateComponentsView() {
        addSubview(dateComponentsView)
        
        dateComponentsView.onTapToBack = { [unowned self] in
            self.onChangeSection?(.days)
        }
        dateComponentsView.onTapToYear = { [unowned self] in
            self.onChangeSection?(.years)
        }
    }
    
    private func setupCollectionView() {
        addSubview(collectionView)
        
        collectionView.bounces = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.register(CalendarMonthCell.self, forCellWithReuseIdentifier: CalendarMonthCell.identifier)
        collectionView.delegate = adapter
        collectionView.dataSource = adapter
    }
    
    private func setupConstraints() {
        dateComponentsView.height(52)
        [dateComponentsView.top(), dateComponentsView.leading(), dateComponentsView.trailing()].toSuperview()
        
        [collectionView.bottom(), collectionView.leading(), collectionView.trailing()].toSuperview()
        dateComponentsView.bottomToTop().to(collectionView, addTo: self)
    }
    
}

private final class CalendarMonthsViewAdapter: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var months: [CalendarMonthEntity] = []
    
    var onSelectMonth: ((Int) -> Void)?
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return months.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarMonthCell.identifier, for: indexPath) as! CalendarMonthCell
        cell.configure(entity: months[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelectMonth?(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right + 20)) / 3
        return CGSize(width: width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}
