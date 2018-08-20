//
//  NumberPicker.swift
//  Agile diary
//
//  Created by i.kharabet on 20.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

final class NumberPicker: UIView {
    
    @IBOutlet fileprivate weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        }
    }
    
    var numbers: [Int] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var shouldAddZero = true
    
    fileprivate var currentNumber: Int = 0
    
    var didChangeNumber: ((Int) -> Void)?
    
    func scrollToNumber(_ number: Int) {
        guard let index = numbers.index(of: number) else { return }
        
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0),
                                    at: .centeredVertically,
                                    animated: false)
    }
    
}

extension NumberPicker: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NumberPickerCell",
                                                      for: indexPath) as! NumberPickerCell
        
        cell.shouldAddZero = shouldAddZero
        let number = numbers.item(at: indexPath.item) ?? 0
        cell.number = number
        cell.isPicked = number == currentNumber
        
        return cell
    }
    
}

extension NumberPicker: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height / 3
        return CGSize(width: collectionView.frame.width, height: height)
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

fileprivate extension NumberPicker {
    
    func scrollToCenterOfCurrentCell() {
        let limitedIndex = getIndexOfCenterItem()
        let indexPath = IndexPath(item: limitedIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }
    
    func getIndexOfCenterItem() -> Int {
        let cellHeight = collectionView.frame.height / 3
        let currentIndex = Int(round(collectionView.contentOffset.y / cellHeight))
        return min(numbers.count - 1, max(0, currentIndex))
    }
    
    func handleNumberChange() {
        let limitedIndex = getIndexOfCenterItem()
        
        let number = numbers.item(at: limitedIndex) ?? 0
        
        if number != currentNumber {
            currentNumber = number
        }
        
        didChangeNumber?(currentNumber)
    }
    
}

final class NumberPickerCell: UICollectionViewCell {
    
    @IBOutlet private var numberLabel: UILabel!
    
    var shouldAddZero = true
    
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
            numberLabel.textColor = isPicked ? AppTheme.current.colors.selectedElementColor : AppTheme.current.colors.inactiveElementColor
        }
    }
    
}
