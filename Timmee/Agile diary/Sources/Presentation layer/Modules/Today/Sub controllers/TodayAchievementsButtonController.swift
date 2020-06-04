//
//  TodayAchievementsButtonController.swift
//  Agile diary
//
//  Created by Илья Харабет on 31/05/2020.
//  Copyright © 2020 Mesterra. All rights reserved.
//

import UIKit
import UIComponents

final class TodayAchievementsButtonController {
    
    unowned let parent: UIViewController
    
    unowned var achievementsButton: UIButton!
    unowned var achievementsButtonContainer: UIView!
    private let achievementsBadge = BadgeView(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
    
    private let observer = ServicesAssembly.shared.achievementsService.achievementsObserver()
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    
    init(parent: UIViewController) {
        self.parent = parent
    }
    
    func subscribeOnAchievementsUpdate() {
        feedbackGenerator.prepare()
        
        observer.setActions(
            onInitialFetch: nil,
            onItemsCountChange: { [unowned self] count in
                self.animateBadgeUpdate()
                self.achievementsBadge.title = "\(count)"
            },
            onItemChange: nil,
            onBatchUpdatesStarted: nil,
            onBatchUpdatesCompleted: nil
        )
        observer.setMapping { $0 as! AchievementEntity }
        
        observer.fetchInitialEntities()
    }
    
    func setup() {
        achievementsButton.addTarget(self, action: #selector(onTapAchievementsButton), for: .touchUpInside)
        
        achievementsButtonContainer.addSubview(achievementsBadge)
        achievementsBadge.isUserInteractionEnabled = false
        
        achievementsBadge.height(16)
        achievementsBadge.width(greatherOrEqual: 16)
        [achievementsBadge.bottom(-2), achievementsBadge.centerX()]
            .to(achievementsButton, addTo: achievementsButtonContainer)
    }
    
    private func animateBadgeUpdate() {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.autoreverse],
            animations: {
                self.achievementsBadge.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            },
            completion: { _ in
                self.achievementsBadge.transform = .identity
                self.feedbackGenerator.impactOccurred()
            }
        )
    }
    
    @objc private func onTapAchievementsButton() {
        parent.present(UINavigationController(rootViewController: AchievementsScreen()), animated: true, completion: nil)
    }
    
}
