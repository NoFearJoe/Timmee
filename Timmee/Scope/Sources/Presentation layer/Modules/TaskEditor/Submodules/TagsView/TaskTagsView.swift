//
//  TaskTagsView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 22.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

final class TaskTagsView: HiddingParameterView {
    
    @IBOutlet private var iconView: UIImageView!
    @IBOutlet private var placeholderLabel: UILabel! {
        didSet {
            placeholderLabel.text = "tags_picker".localized
            placeholderLabel.textColor = AppTheme.current.secondaryTintColor
            placeholderLabel.isHidden = true
        }
    }
    @IBOutlet private var tagsView: UICollectionView! {
        didSet {
            addTapGestureRecognizer(to: tagsView)
            tagsView.register(UINib(nibName: "TagCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TagCollectionViewCell")
            tagsView.delegate = tagsAdapter
            tagsView.dataSource = tagsAdapter
        }
    }
    
    private let tagsAdapter = TaskTagsCollectionAdapter()
    
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
            tagsAdapter.tags = tags.sorted(by: { $0.title < $1.title })
            placeholderLabel.isHidden = !tags.isEmpty
            tagsView.reloadData()
        }
    }
    
    private let filledIconColor = AppTheme.current.blueColor
    private let notFilledIconColor = AppTheme.current.thirdlyTintColor
    
    private func setFilled(_ isFilled: Bool) {
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
    
    private func addTapGestureRecognizer(to view: UIView) {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onTap))
        view.addGestureRecognizer(recognizer)
    }
    
    @objc private func onTap() {
        didTouchedUp?()
    }
    
}

final class TaskTagsCollectionAdapter: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var tags: [Tag] = []
    
    var onSelectTag: ((Tag) -> Void)?
    
    var cellSize: (CGFloat) -> CGSize = { width in CGSize(width: width + 10, height: 24) }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell",
                                                      for: indexPath) as! TagCollectionViewCell
        
        if let tag = tags.item(at: indexPath.row) {
            cell.title = tag.title
            cell.color = tag.color
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let tag = tags.item(at: indexPath.row) {
            return cellSize(tag.width)
        }
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tag = tags.item(at: indexPath.item) else { return }
        onSelectTag?(tag)
    }
    
}

extension Tag {
    var width: CGFloat {
        return (title as NSString).size(withAttributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]).width
    }
}
