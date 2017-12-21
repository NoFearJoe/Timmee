//
//  TaskTagsView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 22.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class TaskTagsView: UIView {
    
    @IBOutlet fileprivate var iconView: UIImageView!
    @IBOutlet fileprivate var placeholderLabel: UILabel! {
        didSet {
            placeholderLabel.text = "tags_picker".localized
            placeholderLabel.textColor = AppTheme.current.secondaryTintColor
            placeholderLabel.isHidden = true
        }
    }
    @IBOutlet fileprivate var tagsView: UICollectionView! {
        didSet {
            addTapGestureRecognizer(to: tagsView)
        }
    }
    
    var didChangeFilledState: ((Bool) -> Void)?
    var didTouchedUp: (() -> Void)?
    
    var isFilled: Bool = false {
        didSet {
            setFilled(isFilled)
            didChangeFilledState?(isFilled)
        }
    }
    
    var tags: [Tag] = [] {
        didSet {
            sortedTags = tags.sorted(by: { $0.0.title < $0.1.title })
            placeholderLabel.isHidden = !tags.isEmpty
            tagsView.reloadData()
        }
    }
    
    var sortedTags: [Tag] = []
    
    fileprivate let filledIconColor = AppTheme.current.blueColor
    fileprivate let notFilledIconColor = AppTheme.current.thirdlyTintColor
    
    fileprivate func setFilled(_ isFilled: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.iconView.tintColor = isFilled ? self.filledIconColor : self.notFilledIconColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTapGestureRecognizer(to: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addTapGestureRecognizer(to: self)
    }
    
    fileprivate func addTapGestureRecognizer(to view: UIView) {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        view.addGestureRecognizer(recognizer)
    }
    
    @objc fileprivate func onTap() {
        didTouchedUp?()
    }
    
}

extension TaskTagsView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell",
                                                      for: indexPath) as! TagCollectionViewCell
        
        if let tag = sortedTags.item(at: indexPath.row) {
            cell.title = tag.title
            cell.color = tag.color
        }
        
        return cell
    }
    
}

extension TaskTagsView: UICollectionViewDelegate {}

extension TaskTagsView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let tag = sortedTags.item(at: indexPath.row) {
            let width = (tag.title as NSString).size(attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 16)
            ]).width
            return CGSize(width: width + 10, height: 24)
        }
        return .zero
    }
    
}

final class TagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var colorView: TagCollectionColorView!
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var color: UIColor {
        get { return colorView.color }
        set { colorView.color = newValue }
    }
    
}

final class TagCollectionColorView: UIView {
    
    var color: UIColor {
        get { return backgroundColor ?? .clear }
        set { backgroundColor = newValue }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.height * 0.5
    }
    
}
