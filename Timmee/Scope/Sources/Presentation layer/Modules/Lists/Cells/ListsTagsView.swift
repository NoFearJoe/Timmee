//
//  ListsTagsView.swift
//  Scope
//
//  Created by i.kharabet on 15/05/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class ListsTagsView: UIView {
    
    var onSelectTag: ((Tag) -> Void)?
    
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.textColor = AppTheme.current.secondaryTintColor
        }
    }
    
    @IBOutlet private var tagsView: UICollectionView! {
        didSet {
            tagsView.register(UINib(nibName: "TagCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TagCollectionViewCell")
            tagsView.delegate = tagsAdapter
            tagsView.dataSource = tagsAdapter
        }
    }
    
    private lazy var tagsAdapter: TaskTagsCollectionAdapter = {
        let adapter = TaskTagsCollectionAdapter()
        adapter.onSelectTag = { [unowned self] tag in
            self.onSelectTag?(tag)
        }
        adapter.cellSize = { width in return CGSize(width: width + 16, height: 32) }
        return adapter
    }()
    
    func configure(tags: [Tag]) {
        titleLabel.text = "tags_picker".localized.uppercased()
        tagsAdapter.tags = tags
        tagsView.reloadData()
    }
    
}
