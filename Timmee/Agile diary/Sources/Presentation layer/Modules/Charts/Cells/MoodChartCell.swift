//
//  MoodChartCell.swift
//  Agile diary
//
//  Created by Илья Харабет on 20/03/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class MoodChartCell: BaseChartCell {
    
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.text = "average_mood".localized
            titleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        }
    }
    
    @IBOutlet private var moodLabel: UILabel! {
        didSet {
            moodLabel.font = AppTheme.current.fonts.medium(24)
        }
    }
    
    @IBOutlet private var moodIconView: UIImageView!
    
    @IBOutlet private var fullProgressButton: UIButton! {
        didSet {
            fullProgressButton.setTitle("show_full_progress".localized, for: .normal)
            fullProgressButton.tintColor = AppTheme.current.colors.mainElementColor
            fullProgressButton.isHidden = true
        }
    }
    
    @IBAction private func showFullProgress() {
        onShowFullProgress?()
    }
    
    private let moodService = ServicesAssembly.shared.moodServce
    
    override func update(sprint: Sprint) {
        fullProgressButton.isHidden = !(ProVersionPurchase.shared.isPurchased() || Environment.isDebug)
        
        let moods = moodService.fetchMoods(sprint: sprint)
        let averageMood = moods.averageKind()
        
        moodLabel.text = averageMood.localized
        switch averageMood {
        case .veryBad, .bad:
            moodLabel.textColor = AppTheme.current.colors.wrongElementColor
        case .normal:
            moodLabel.textColor = AppTheme.current.colors.incompleteElementColor
        case .good, .veryGood:
            moodLabel.textColor = AppTheme.current.colors.selectedElementColor
        }
        moodIconView.image = UIImage(named: averageMood.icon)
    }
    
    override static func size(for collectionViewSize: CGSize) -> CGSize {
        return CGSize(width: collectionViewSize.width - 30, height: 90)
    }
    
}
