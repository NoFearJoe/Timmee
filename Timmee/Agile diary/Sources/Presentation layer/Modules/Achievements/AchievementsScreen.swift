//
//  AchievementsScreen.swift
//  Agile diary
//
//  Created by Илья Харабет on 01/06/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import UIComponents

final class AchievementsScreen: BaseViewController {
    
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    private let placeholder = ScreenPlaceholderView()
    
    private let achievementsService = EntityServicesAssembly.shared.achievementsService
    
    private let queue = DispatchQueue(label: "achievements_screen_queue")
    
    private var achievementEntities: [AchievementEntity] = []
    private var achievementViewModels: [AchievementViewModel] = []
    
    override func prepare() {
        super.prepare()
        
        title = "achievements".localized
        
        setupCloseButton()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        view.addSubview(collectionView)
        collectionView.allEdges().toSuperview()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = nil
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(AchievementCell.self, forCellWithReuseIdentifier: AchievementCell.identifier)
        collectionView.contentInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        
        placeholder.setup(into: view)
        placeholder.setVisible(false, animated: false)
    }
    
    override func refresh() {
        super.refresh()
        
        queue.async {
            self.achievementEntities = self.achievementsService.fetchAchievementEntitiesInBackground()
            self.achievementViewModels = AchievementViewModelsMapper.map(achievements: self.achievementEntities)
            
            DispatchQueue.main.async {
                self.placeholder.setVisible(self.achievementViewModels.isEmpty, animated: true)
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.estimatedItemSize = CGSize(width: collectionView.bounds.width - 30, height: 72)
    }
    
}

extension AchievementsScreen: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        achievementViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AchievementCell.identifier, for: indexPath) as! AchievementCell
        
        cell.configure(model: achievementViewModels[indexPath.item])
        
        return cell
    }
    
}

extension AchievementsScreen: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}

extension AchievementsScreen: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        12
    }
    
}
