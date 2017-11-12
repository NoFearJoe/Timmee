//
//  ColorPicker.swift
//  Timmee
//
//  Created by Ilya Kharabet on 22.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class ColorPicker: UIView {
    
    var colors: [UIColor] = [] {
        didSet {
            colorsCollectionView?.reloadData()
        }
    }
    
    var onSelectColor: ((UIColor) -> Void)?
    
    @IBInspectable var selectedColorIndex: Int = 0 {
        didSet {
            guard selectedColorIndex >= 0 else { return }
            guard oldValue != selectedColorIndex else { return }
            if colors.indices.contains(selectedColorIndex) {
                let color = colors[selectedColorIndex]
                onSelectColor?(color)
                
                colorsCollectionView?.reloadItems(at: [IndexPath(item: oldValue, section: 0),
                                                       IndexPath(item: selectedColorIndex, section: 0)])
            }
        }
    }
    
    @IBOutlet fileprivate weak var colorsCollectionView: UICollectionView! {
        didSet {
            colorsCollectionView.reloadData()
        }
    }
    
}

extension ColorPicker: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorPickerCell",
                                                      for: indexPath) as! ColorPickerCell
        
        cell.color = colors.item(at: indexPath.item)
        cell.isPicked = indexPath.item == selectedColorIndex
        
        return cell
    }
    
}

extension ColorPicker: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedColorIndex = indexPath.item
    }
    
}

final class ColorPickerCell: UICollectionViewCell {
    
    @IBOutlet fileprivate weak var pickedImageView: UIImageView! {
        didSet {
            pickedImageView.tintColor = AppTheme.current.foregroundColor
        }
    }
    
    @IBInspectable var isPicked: Bool = false {
        didSet {
            pickedImageView.isHidden = !isPicked
        }
    }
    
    var color: UIColor? {
        didSet {
            backgroundColor = color
        }
    }
    
}
