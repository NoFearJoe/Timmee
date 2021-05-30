//
//  ShopCategoriesViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 13.11.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import FirebaseStorage

final class ShopCategoriesViewController: BaseViewController {
    
    var sprintID: String?
        
    @IBOutlet private var collectionView: UICollectionView! {
        didSet {
            collectionView.register(ShopCategoryCell.self, forCellWithReuseIdentifier: ShopCategoryCell.identifier)
        }
    }
    
    @IBOutlet private var placeholderContainer: UIView!
    let placeholderView = PlaceholderView.loadedFromNib()
    
    @IBOutlet private var loadingView: LoadingView!
    
    private let collectionsLoader = HabitsCollectionsLoader.shared
    
    private var categories: [HabitsCollection] = []
    
    override func prepare() {
        super.prepare()
        setupPlaceholder()
        
        loadingView.isHidden = false
        collectionsLoader.loadHabitsCollections(success: { [weak self] collections in
            self?.loadingView.isHidden = true
            self?.categories = collections
            self?.collectionView.reloadData()
            self?.placeholderContainer.isHidden = true
        }) { [weak self] error in
            self?.loadingView.isHidden = true
            self?.placeholderContainer.isHidden = false
        }
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        setupPlaceholderAppearance()
        collectionView.backgroundColor = AppTheme.current.colors.middlegroundColor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let categoryViewController = segue.destination as? ShopCategoryViewController {
            categoryViewController.sprintID = sprintID
            categoryViewController.collection = sender as? HabitsCollection
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
}

extension ShopCategoriesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShopCategoryCell.identifier, for: indexPath) as! ShopCategoryCell
        if let category = categories.item(at: indexPath.item) {
            cell.configure(title: category.title, emoji: category.emoji)
        }
        return cell
    }
    
}

extension ShopCategoriesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let category = categories.item(at: indexPath.item) else { return }
        performSegue(withIdentifier: "ShowCategory", sender: category)
    }
    
}

extension ShopCategoriesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat
        if UIDevice.current.isIpad {
            columns = 2
        } else if UIScreen.main.nativeBounds.height <= 1136 {
            columns = 1
        } else {
            columns = 1
        }
        
        let width = (collectionView.bounds.width - 30 - 10 * (columns - 1)) / columns
        
        let height: CGFloat = 80
//        if UIDevice.current.isIpad {
//            height = width
//        } else if UIScreen.main.nativeBounds.height <= 1136 {
//            height = 64
//        } else {
//            height = width * 0.75
//        }
        
        return CGSize(width: width, height: height)
    }
    
}

private extension ShopCategoriesViewController {
    
    func setupPlaceholder() {
        placeholderView.icon = UIImage(imageLiteralResourceName: "history") // TODO: Нужна другая иконка
        placeholderView.title = "error".localized
        placeholderView.subtitle = "error_while_loading_habits_collections".localized
        placeholderView.setup(into: placeholderContainer)
        placeholderContainer.isHidden = true
    }
    
    func setupPlaceholderAppearance() {
        placeholderView.backgroundColor = .clear
        placeholderView.titleLabel.font = AppTheme.current.fonts.medium(18)
        placeholderView.subtitleLabel.font = AppTheme.current.fonts.regular(14)
        placeholderView.titleLabel.textColor = AppTheme.current.textColorForTodayLabelsOnBackground
        placeholderView.subtitleLabel.textColor = AppTheme.current.textColorForTodayLabelsOnBackground
    }
    
}

final class ShopCategoryCell: UICollectionViewCell {
    
    static let identifier = "ShopCategoryCell"
    
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupAppearance()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(title: String, emoji: String) {
        titleLabel.text = title
        emojiLabel.text = emoji
    }
    
    func setupAppearance() {
        layer.cornerRadius = 12
        configureShadow(radius: 4, opacity: 0.1)
        backgroundColor = AppTheme.current.colors.foregroundColor
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
    }
    
    private func setupViews() {
        contentView.addSubview(emojiLabel)
        emojiLabel.textAlignment = .center
        emojiLabel.font = AppTheme.current.fonts.regular(32)
        [emojiLabel.leading(12), emojiLabel.centerY()].toSuperview()
        let emojiLabelTop = emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8)
        emojiLabelTop.priority = .defaultLow
        emojiLabelTop.isActive = true
        
        contentView.addSubview(titleLabel)
        titleLabel.numberOfLines = 0
        titleLabel.font = AppTheme.current.fonts.regular(18)
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        titleLabel.leadingToTrailing(12).to(emojiLabel, addTo: contentView)
        [titleLabel.centerY(), titleLabel.trailing(12)].toSuperview()
        titleLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8).isActive = true
    }
    
}
