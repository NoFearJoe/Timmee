//
//  NumberPadAdapter.swift
//  Test
//
//  Created by i.kharabet on 13.10.17.
//  Copyright © 2017 i.kharabet. All rights reserved.
//

import class Foundation.NSObject
import struct Foundation.IndexPath
import func Foundation.ceil
import struct UIKit.CGSize
import struct UIKit.CGFloat
import class UIKit.UICollectionView
import class UIKit.UICollectionViewCell
import class UIKit.UICollectionViewLayout
import protocol UIKit.UICollectionViewDelegate
import protocol UIKit.UICollectionViewDataSource
import protocol UIKit.UICollectionViewDelegateFlowLayout

protocol NumberPadAdapterOutput: class {
    func didSelectItem(with kind: NumberPadItem.Kind)
}

final class NumberPadAdapter: NSObject {
    
    var items: [NumberPadItem] = []
    
    weak var output: NumberPadAdapterOutput?
    
    var numberOfColumns: Int = 3
    var interitemSpacing: CGFloat = 20
    
    var maxSize: CGFloat = 80
    
}

extension NumberPadAdapter: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.item]
        
        let cell: BasePadCell
        switch item.style {
        case .number:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NumberPadCell", for: indexPath) as! NumberPadCell
        case .symbol:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SymbolPadCell", for: indexPath) as! NumberPadCell
        case .icon:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconPadCell", for: indexPath) as! IconPadCell
        }
        
        cell.configure(with: item)
        
        return cell
    }
    
}

extension NumberPadAdapter: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        output?.didSelectItem(with: item.kind)
    }
    
}

extension NumberPadAdapter: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interitemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - interitemSpacing * CGFloat(numberOfColumns - 1)
        let itemWidth = availableWidth / CGFloat(numberOfColumns)
        
        let numberOfRows = Int(ceil(Double(items.count) / Double(numberOfColumns)))
        let availableHeight = collectionView.frame.height - interitemSpacing * CGFloat(numberOfRows)
        let itemHeight = availableHeight / CGFloat(numberOfRows)
        
        let itemSize = min(maxSize, min(itemWidth, itemHeight))
        
        return CGSize(width: itemSize, height: itemSize)
    }
    
}
