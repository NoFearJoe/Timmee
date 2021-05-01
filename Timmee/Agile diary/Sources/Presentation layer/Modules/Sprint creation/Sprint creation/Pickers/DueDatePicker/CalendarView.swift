//
//  CalendarView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 20.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class CalendarView: UIView {
    
    @IBOutlet weak var calendarView: UICollectionView! {
        didSet {
            calendarView.delegate = self
            calendarView.dataSource = self
            
            (calendarView.collectionViewLayout as! CalendarViewLayout).delegate = self
        }
    }
    
    var calendar: (calendar: Workset.Calendar, months: [Workset.Calendar.MonthEntry])!
    
    var selectedDateIndex = 1 {
        didSet {
            scrollToSelectedCell()
        }
    }
    
    var shouldDrawSeparator = false
    
    var didSelectItemAtIndex: ((Int) -> Void)?
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard shouldDrawSeparator else { return }
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setStrokeColor(tintColor.cgColor)
            context.setLineWidth(0.5)
            context.move(to: CGPoint(x: 0, y: rect.size.height - 0.5))
            context.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height - 0.5))
            context.strokePath()
            context.move(to: CGPoint(x: 0, y: 0.5))
            context.addLine(to: CGPoint(x: rect.size.width, y: 0.5))
            context.strokePath()
        }
    }
    
    
    func scrollToSelectedCell() {
        let daysCount = calendar.calendar.entriesCount
        if 0..<daysCount ~= selectedDateIndex {
            let visibleItems = calendarView.indexPathsForVisibleItems.sorted()
            
            var targetIndexPath = IndexPath(item: selectedDateIndex, section: 0)
            var scrollPosition = UICollectionView.ScrollPosition.centeredHorizontally
            
            if let firstIndexPath = visibleItems.first, targetIndexPath <= firstIndexPath {
                scrollPosition = .left
                if selectedDateIndex - 1 >= 0 && !visibleItems.contains(IndexPath(item: selectedDateIndex - 1, section: 0)) {
                    targetIndexPath = IndexPath(item: selectedDateIndex - 1, section: 0)
                }
            } else if let lastIndexPath = visibleItems.last, targetIndexPath >= lastIndexPath {
                scrollPosition = .right
                if selectedDateIndex + 1 < daysCount && !visibleItems.contains(IndexPath(item: selectedDateIndex + 1, section: 0)) {
                    targetIndexPath = IndexPath(item: selectedDateIndex + 1, section: 0)
                }
            }
            
            if !(visibleItems.contains(targetIndexPath) && scrollPosition == .centeredHorizontally) {
                calendarView.scrollToItem(at: targetIndexPath,
                                          at: scrollPosition,
                                          animated: true)
            }
        }
    }
    
}


extension CalendarView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return calendar.calendar.entriesCount
        }
        return calendar.months.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDayCell", for: indexPath) as! CalendarDayCell
            
            if let day = calendar.calendar.entry(at: indexPath.item) {
                cell.isWeekend = day.isWeekend

                cell.dayNameLabel.text = day.dayName.uppercased()
                cell.dayNumberLabel.text = "\(day.dayNumber)"
                
                let notSelectedState: UIControl.State = day.isEnabled ? .normal : .disabled
                cell.dayNameLabel.state = notSelectedState
                cell.dayNumberLabel.state = selectedDateIndex == indexPath.item ? .selected : notSelectedState
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarMonthCell", for: indexPath) as! CalendarMonthCell
            
            cell.month = calendar.months[indexPath.item].name
            
            return cell
        }
    }
    
}

extension CalendarView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let entry = calendar.calendar.entry(at: indexPath.item) {
            if entry.isEnabled {
                didSelectItemAtIndex?(indexPath.item)
            }
        }
        
    }
    
}

extension CalendarView: CalendarViewLayoutDelegate {

    func daysCount(forIndex index: Int) -> Int {
        return calendar.months[index].daysCount
    }
    
    func month(forIndex index: Int) -> String {
        return calendar.months[index].name
    }

}


protocol CalendarViewLayoutDelegate: UICollectionViewDelegateFlowLayout {
    func daysCount(forIndex index: Int) -> Int
    func month(forIndex index: Int) -> String
}

final class CalendarViewLayout: UICollectionViewFlowLayout {

    var contentSize = CGSize.zero
    
    var attributes = [[UICollectionViewLayoutAttributes]]()
    
    weak var delegate: CalendarViewLayoutDelegate?
    
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
    
    override func invalidateLayout() {
        super.invalidateLayout()
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func prepare() {
        attributes = [[UICollectionViewLayoutAttributes]]()

        guard let collectionView = self.collectionView else { return }
        
        if collectionView.numberOfSections == 0 { return }
        
        let sectionsCount = collectionView.numberOfSections
        
        var contentWidth: CGFloat = 0
        
        for section in 0..<sectionsCount {
            if section == 0 {
                var attrs = [UICollectionViewLayoutAttributes]()
                let items = collectionView.numberOfItems(inSection: section)
                
                for item in 0..<items {
                    let indexPath = IndexPath(item: item, section: section)
                    let a = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    
                    a.frame = CGRect(x: CGFloat(item) * 48, y: 0, width: 48, height: 62)
                    
                    attrs.append(a)
                }
                
                contentWidth = CGFloat(items) * CGFloat(48)
                
                attributes.append(attrs)
            } else if section == 1 {
                var attrs = [UICollectionViewLayoutAttributes]()
                let items = collectionView.numberOfItems(inSection: section)
                
                var xOffset: CGFloat = 0
                
                for item in 0..<items {
                    let indexPath = IndexPath(item: item, section: section)
                    let a = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    
                    let month = delegate?.month(forIndex: item) ?? ""
                    let daysCount = delegate?.daysCount(forIndex: item) ?? 0
                    
                    let maxWidth = CGFloat(daysCount) * CGFloat(48)
                    let width = (month as NSString).size(withAttributes: [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12) ]).width + 4
                    let minOffset = xOffset
                    let maxOffset = (xOffset + maxWidth) - width
                    let offsetX = (collectionView.frame.width * 0.5 - width * 0.5) + collectionView.contentOffset.x
                    let limitedOffset = min(maxOffset, max(minOffset, offsetX))
                    a.frame = CGRect(x: limitedOffset, y: 62, width: width, height: 20)
                    
                    attrs.append(a)
                    
                    xOffset += maxWidth
                    
                    attributes.append(attrs)
                }
            }
        }
        
        contentSize = CGSize(width: contentWidth, height: 62 + 20)
    }

}
