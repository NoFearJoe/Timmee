//
//  TaskCategoryPicker.swift
//  Timmee
//
//  Created by Ilya Kharabet on 17.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class TaskCategoryPicker: UICollectionView {
    
    var didChangeCategory: ((TaskCategory) -> Void)?
    
    var category: TaskCategory = .other {
        didSet {
            reloadData()
            didChangeCategory?(category)
        }
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        dataSource = self
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dataSource = self
        delegate = self
    }
    
}

extension TaskCategoryPicker: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TaskCategory.all.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskCategoryCell",
                                                      for: indexPath) as! TaskCategoryCell
        
        let category = TaskCategory(categoryCode: indexPath.item)
        
        cell.category = category
        
        cell.isPicked = category == self.category
        
        return cell
    }
    
}

extension TaskCategoryPicker: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        category = TaskCategory(categoryCode: indexPath.item)
    }

}

extension TaskCategoryPicker: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width
        let width = availableWidth / CGFloat(TaskCategory.all.count)
        let height = collectionView.frame.height
        return CGSize(width: width, height: height)
    }

}

class TaskCategoryCell: UICollectionViewCell {

    @IBOutlet fileprivate weak var iconView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    
    var category: TaskCategory = .other {
        didSet {
            iconView.image = category.icon
            titleLabel.text = category.title
        }
    }
    
    var isPicked: Bool = false {
        didSet {
            iconView.alpha = isPicked ? 1 : 0.35
            titleLabel.alpha = isPicked ? 1 : 0.35
        }
    }

}

final class TaskImportancyPicker: UIView {

    @IBOutlet fileprivate weak var iconView: UIImageView!
    
    var isPicked: Bool = false {
        didSet {
            iconView.image = isPicked ? #imageLiteral(resourceName: "important_active") : #imageLiteral(resourceName: "important_inactive")
        }
    }
    
    var onPick: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isUserInteractionEnabled = true
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        addGestureRecognizer(recognizer)
    }
    
    @objc fileprivate func onTap() {
        isPicked = !isPicked
        onPick?(isPicked)
    }

}
