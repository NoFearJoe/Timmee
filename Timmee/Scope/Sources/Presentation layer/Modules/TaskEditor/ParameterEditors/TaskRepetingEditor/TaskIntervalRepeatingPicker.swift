//
//  TaskIntervalRepeatingPicker.swift
//  Timmee
//
//  Created by Ilya Kharabet on 27.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

protocol TaskIntervalRepeatingPickerInput: class {
    func setRepeatingMask(_ mask: RepeatMask)
}

protocol TaskIntervalRepeatingPickerOutput: class {
    func didSelectInterval(_ interval: Int, unit: RepeatUnit)
}

final class TaskIntervalRepeatingPicker: UIViewController {

    weak var output: TaskIntervalRepeatingPickerOutput?
    weak var container: TaskParameterEditorOutput?
    
    @IBOutlet fileprivate weak var topLabel: UILabel!
    @IBOutlet fileprivate weak var numbersCollectionView: UICollectionView!
    @IBOutlet fileprivate weak var unitsCollectionView: UICollectionView!
    
    var numbers = Array(2...30)
    var units = [RepeatUnit.day, .week, .month, .year]
    
    var selectedNumber: Int = 2
    var selectedUnit: RepeatUnit = .day
    
    var shouldSendInitialInterval = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        topLabel.textColor = AppTheme.current.tintColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if shouldSendInitialInterval {
            output?.didSelectInterval(selectedNumber, unit: selectedUnit)
        }
    }

}

extension TaskIntervalRepeatingPicker: TaskIntervalRepeatingPickerInput {

    func setRepeatingMask(_ mask: RepeatMask) {
        if case .every(let unit) = mask.type {
            selectedUnit = unit
            selectedNumber = mask.value
        }
        shouldSendInitialInterval = mask.type == .never
        
        updateTopLabel()
    }

}

extension TaskIntervalRepeatingPicker: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == numbersCollectionView {
            return numbers.count
        } else if collectionView == unitsCollectionView {
            return units.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == numbersCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskIntervalRepeatingPickerNumberCell",
                                                          for: indexPath) as! TaskIntervalRepeatingPickerNumberCell
            
            let number = numbers[indexPath.item]
            cell.number = number
            cell.state = selectedNumber == number ? .selected : .normal
            cell.setupAppearance()
            
            return cell
        } else if collectionView == unitsCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskIntervalRepeatingPickerUnitCell",
                                                          for: indexPath) as! TaskIntervalRepeatingPickerUnitCell
            
            let unit = units[indexPath.item]
            cell.unit = unit.localized(with: selectedNumber)
            cell.isPicked = selectedUnit == unit
            
            return cell
        }
        return UICollectionViewCell()
    }

}

extension TaskIntervalRepeatingPicker: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == numbersCollectionView {
            selectedNumber = numbers[indexPath.item]
            
            numbersCollectionView.reloadData()
            unitsCollectionView.reloadData()
            
            output?.didSelectInterval(selectedNumber, unit: selectedUnit)
            
            updateTopLabel()
        } else if collectionView == unitsCollectionView {
            selectedUnit = units[indexPath.item]
            
            unitsCollectionView.reloadData()
            
            output?.didSelectInterval(selectedNumber, unit: selectedUnit)
            
            updateTopLabel()
        }
    }

}

extension TaskIntervalRepeatingPicker: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == numbersCollectionView {
            return CGSize(width: 38, height: 38)
        } else if collectionView == unitsCollectionView {
            let width = collectionView.frame.width / CGFloat(units.count)
            return CGSize(width: width, height: 32)
        }
        return .zero
    }

}



extension TaskIntervalRepeatingPicker: TaskParameterEditorInput {
    
    var requiredHeight: CGFloat {
        return 128
    }
    
}

fileprivate extension TaskIntervalRepeatingPicker {

    func updateTopLabel() {
        if selectedUnit == .week {
            topLabel.text = "every_n_weeks".localized(with: selectedNumber)
        } else {
            topLabel.text = "every_n_units".localized(with: selectedNumber)
        }
    }

}



final class TaskIntervalRepeatingPickerNumberCell: UICollectionViewCell {

    @IBOutlet fileprivate weak var numberLabel: DayNumberLabel!
    
    var number: Int = 0 {
        didSet {
            numberLabel.text = "\(number)"
        }
    }
    
    var state: UIControl.State = .normal {
        didSet {
            numberLabel.state = state
        }
    }
    
    func setupAppearance() {
        numberLabel.setupAppearance(isWeekend: false)
    }

}

final class TaskIntervalRepeatingPickerUnitCell: UICollectionViewCell {

    @IBOutlet fileprivate weak var unitLabel: UILabel!
    
    var unit: String = "" {
        didSet {
            unitLabel.text = unit
        }
    }
    
    var isPicked: Bool = false {
        didSet {
            unitLabel.textColor = isPicked ? AppTheme.current.blueColor : AppTheme.current.tintColor
        }
    }

}
