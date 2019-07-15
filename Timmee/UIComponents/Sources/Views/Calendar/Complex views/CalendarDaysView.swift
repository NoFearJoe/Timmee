//
//  CalendarDaysView.swift
//  UIComponents
//
//  Created by i.kharabet on 28/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import Workset

final class CalendarDaysView: UIView {
    
    var onSelectDate: ((Date?) -> Void)?
    var badgeValue: ((Date) -> String?)?
    
    var maximumHeight: CGFloat {
        let staticHeight = 52 + 24 + collectionView.contentInset.top + collectionView.contentInset.bottom
        
        let cellHeight = adapter.calculateCellSize(collectionView: collectionView)
        let verticalSpacing: CGFloat = 10
        let maxRows: CGFloat = 6
        let collectionViewHeight = cellHeight * maxRows + verticalSpacing * (maxRows - 1)
        
        return staticHeight + collectionViewHeight
    }
    
    private lazy var dateComponentsView = CalendarDaysDateComponentsView(design: design)
    private lazy var weekdaysView = CalendarWeekdaysView(design: design)
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: CalendarDaysCollectionLayout())
    
    private lazy var adapter: CalendarDaysAdapter = {
        let adapeter = CalendarDaysAdapter()
        adapeter.dataSource = self
        return adapeter
    }()
    
    private let state: CalendarState
    private let design: CalendarDesign
    
    init(state: CalendarState, design: CalendarDesign) {
        self.state = state
        self.design = design
        
        super.init(frame: .zero)
        
        self.adapter.design = design
        
        setupDateComponentsView()
        setupWeekdaysView()
        setupCollectionView()
        setupConstraints()
        
        adapter.onSelectDay = { [unowned self] index in
            self.state.selectedDate = (self.state.currentDate.startOfMonth + (index + 1).asDays) as Date
            self.onSelectDate?(self.state.selectedDate)
            self.reload()
        }
    }
    
    private override init(frame: CGRect) { fatalError() }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    func reload() {
        weekdaysView.configure(weekdays: Calendar.current.localizedShortenedWeekdays)
        
        let startOfMonth = self.state.currentDate
        
        dateComponentsView.configure(date: startOfMonth)
        
        let daysInMonth = startOfMonth.daysInMonth
        let days = (0..<daysInMonth).map { day -> CalendarDayEntity in
            let currentDate = startOfMonth + day.asDays
            return CalendarDayEntity(number: day + 1,
                                     weekday: currentDate.weekday - 1,
                                     isSelected: state.selectedDate.map { currentDate.isWithinSameDay(of: $0) } ?? false,
                                     isCurrent: currentDate.isWithinSameDay(of: Date()),
                                     isDisabled: currentDate.isLower(than: state.minimumDate),
                                     tasksCount: 0)
        }
        adapter.days = days
        collectionView.reloadData()
    }
    
    private func setupDateComponentsView() {
        addSubview(dateComponentsView)
    }
    
    private func setupWeekdaysView() {
        addSubview(weekdaysView)
    }
    
    private func setupCollectionView() {
        addSubview(collectionView)
        
        collectionView.bounces = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.identifier)
        collectionView.delegate = adapter
        collectionView.dataSource = adapter
        (collectionView.collectionViewLayout as! CalendarDaysCollectionLayout).delegate = adapter
    }
    
    private func setupConstraints() {
        dateComponentsView.height(52)
        [dateComponentsView.top(), dateComponentsView.leading(), dateComponentsView.trailing()].toSuperview()
        weekdaysView.height(24)
        [weekdaysView.leading(), weekdaysView.trailing()].toSuperview()
        [collectionView.bottom(), collectionView.leading(), collectionView.trailing()].toSuperview()
        dateComponentsView.bottomToTop().to(weekdaysView, addTo: self)
        weekdaysView.bottomToTop().to(collectionView, addTo: self)
    }
    
}

extension CalendarDaysView: CalendarDaysAdapterDataSource {
    fileprivate func adapter(_ adapter: CalendarDaysAdapter, badgeValueAt indexPath: IndexPath) -> String? {
        let date = self.state.currentDate + (indexPath.item + 1).asDays
        return badgeValue?(date)
    }
}

private protocol CalendarDaysAdapterDataSource: AnyObject {
    func adapter(_ adapter: CalendarDaysAdapter, badgeValueAt indexPath: IndexPath) -> String?
}

private final class CalendarDaysAdapter: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, CalendarDaysCollectionLayoutDelegate {
    
    var days: [CalendarDayEntity] = []
    
    var onSelectDay: ((Int) -> Void)?
    
    var design: CalendarDesign!
    
    weak var dataSource: CalendarDaysAdapterDataSource?
    
    func calculateCellSize(collectionView: UICollectionView) -> CGFloat {
        let dirtySize = (collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right + 60)) / 7
        let roundedSize = dirtySize.rounded()
        return roundedSize
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarDayCell.identifier, for: indexPath) as! CalendarDayCell
        cell.configure(entity: days[indexPath.item], design: design)
        let badgeValue = dataSource?.adapter(self, badgeValueAt: indexPath)
        cell.setBadgeValue(badgeValue)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelectDay?(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = calculateCellSize(collectionView: collectionView)
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, offsetForDayAt indexPath: IndexPath) -> Int {
        return days[indexPath.item].weekday
    }
    
}

protocol CalendarDaysCollectionLayoutDelegate: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, offsetForDayAt indexPath: IndexPath) -> Int
}

final class CalendarDaysCollectionLayout: UICollectionViewFlowLayout {
    
    var contentSize = CGSize.zero
    
    var attributes = [[UICollectionViewLayoutAttributes]]()
    
    weak var delegate: CalendarDaysCollectionLayoutDelegate?
    
    override var collectionViewContentSize : CGSize {
        return self.contentSize
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if attributes.indices.contains(indexPath.section) {
            if attributes[indexPath.section].indices.contains(indexPath.row) {
                return attributes[indexPath.section][indexPath.row]
            }
        }
        return super.layoutAttributesForItem(at: indexPath)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var a = [UICollectionViewLayoutAttributes]()
        for section in attributes {
            let array = section.filter({ (attributes) -> Bool in
                return rect.intersects(attributes.frame)
            })
            a.append(contentsOf: array)
        }
        return a
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func prepare() {
        attributes = [[UICollectionViewLayoutAttributes]]()
        
        guard let collectionView = self.collectionView else { return }
        
        if collectionView.numberOfSections == 0 { return }
        
        for section in 0..<collectionView.numberOfSections {
            var attrs = [UICollectionViewLayoutAttributes]()
            let items = collectionView.numberOfItems(inSection: section)
            
            var y: CGFloat = 0

            for item in 0..<items {
                let indexPath = IndexPath(item: item, section: section)
                let a = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
                let offset = delegate?.collectionView(collectionView, layout: self, offsetForDayAt: indexPath) ?? 0
                let size = delegate?.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) ?? .zero

                if indexPath.item > 0, offset == 0 {
                    y += 10 + size.height
                }
                
                a.frame = CGRect(x: CGFloat(offset) * size.width + CGFloat(offset) * 10,
                                 y: y,
                                 width: size.width,
                                 height: size.height)
                
                attrs.append(a)
            }
            
            attributes.append(attrs)
        }
        
        contentSize = CGSize(width: attributes.last?.max(by: { $0.frame.maxX < $1.frame.maxX })?.frame.maxX ?? 0, height: (attributes.last?.last?.frame.maxY ?? 0))
    }
    
}
