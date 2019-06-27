//
//  NumberPickerView.swift
//  UIComponents
//
//  Created by i.kharabet on 26/06/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class NumberPickerView: UIView {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = false
        if #available(iOSApplicationExtension 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        
        collectionView.register(NumberPickerCell.self, forCellWithReuseIdentifier: "NumberPickerCell")
        
        collectionView.allEdges().toSuperview()
        
        return collectionView
    }()
    
    var numbers: [Int] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var shouldAddZero = true
    
    var alignment: NSTextAlignment = .center
    
    private var currentNumber: Int = -1 {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var currentHighlightedNumber: Int = -1 {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var onChangeNumber: ((Int) -> Void)?
    
    private let design: TimePickerDesign
    
    init(design: TimePickerDesign) {
        self.design = design
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    func scrollToNumber(_ number: Int) {
        guard let index = numbers.index(of: number) else { return }
        
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0),
                                             at: .centeredVertically,
                                             animated: false)
        
            self.handleNumberChange()
        }
    }
    
}

extension NumberPickerView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NumberPickerCell",
                                                      for: indexPath) as! NumberPickerCell
        
        cell.design = design
        cell.shouldAddZero = shouldAddZero
        cell.alignment = alignment
        let number = numbers.item(at: indexPath.item) ?? 0
        cell.number = number
        cell.isPicked = number == currentHighlightedNumber
        
        return cell
    }
    
}

extension NumberPickerView: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = getCellHeight()
        return CGSize(width: collectionView.frame.width - 1, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let cellHeight = getCellHeight()
        return UIEdgeInsets(top: cellHeight, left: 1, bottom: cellHeight, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    private func getCellHeight() -> CGFloat {
        return collectionView.frame.height / 3
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let centralItemIndex = getIndexOfCenterItem()
        let number = numbers.item(at: centralItemIndex) ?? 0
        currentHighlightedNumber = number
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollToCenterOfCurrentCell()
        handleNumberChange()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        scrollToCenterOfCurrentCell()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        handleNumberChange()
    }
    
}

private extension NumberPickerView {
    
    func scrollToCenterOfCurrentCell() {
        let limitedIndex = getIndexOfCenterItem()
        let indexPath = IndexPath(item: limitedIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }
    
    func getIndexOfCenterItem() -> Int {
        let cellHeight = getCellHeight()
        let currentIndex = Int(round(collectionView.contentOffset.y.safeDivide(by: cellHeight)))
        return min(numbers.count - 1, max(0, currentIndex))
    }
    
    func handleNumberChange() {
        let limitedIndex = getIndexOfCenterItem()
        
        let number = numbers.item(at: limitedIndex) ?? 0
        
        if number != currentNumber {
            currentNumber = number
            currentHighlightedNumber = number
            onChangeNumber?(currentNumber)
        }
    }
    
}

final class NumberPickerCell: UICollectionViewCell {
    
    private lazy var numberLabel: UILabel = createNumberLabel()
    
    var shouldAddZero = true
    var alignment: NSTextAlignment = .center {
        didSet {
            numberLabel.textAlignment = alignment
        }
    }
    
    var number: Int {
        get {
            return Int(numberLabel.text ?? "") ?? 0
        }
        set {
            if newValue < 10 && shouldAddZero {
                numberLabel.text = "0" + String(newValue)
            } else {
                numberLabel.text = String(newValue)
            }
        }
    }
    
    var isPicked: Bool = false {
        didSet {
            numberLabel.textColor = isPicked ? design.tintColor : design.thirdlyTintColor
        }
    }
    
    var design: TimePickerDesign!
    
    private func createNumberLabel() -> UILabel {
        let numberLabel = UILabel()
        
        addSubview(numberLabel)
        
        numberLabel.font = design.timeFont
        numberLabel.textAlignment = alignment
        
        numberLabel.allEdges().toSuperview()
        
        return numberLabel
    }
    
}
