//
//  MoodActivityWidget.swift
//  Agile diary
//
//  Created by i.kharabet on 18.03.2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import TasksKit

final class MoodActivityWidget: UIViewController {
    
    private let moodService = ServicesAssembly.shared.moodServce
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var moodButtons: [MoodButton]!
    
    @IBAction private func onTapToMoodButton(_ button: MoodButton) {
        guard let selectedMoodKind = Mood.Kind.allCases.item(at: button.tag) else { return }
        let mood = Mood(kind: selectedMoodKind, date: Date.now.startOfDay)
        view.isUserInteractionEnabled = false
        moodService.createOrUpdateMood(mood, completion: { [weak self] in
            self?.view.isUserInteractionEnabled = true
            self?.selectMoodButton(mood: mood)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "mood_widget_title".localized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleLabel.font = AppTheme.current.fonts.medium(20)
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
    }
    
}

extension MoodActivityWidget: ActivityWidget {
    
    func refresh() {
        if let todayMood = getTodayMood() {
            selectMoodButton(mood: todayMood)
        } else {
            deselectAllMoodButtons()
        }
    }
    
}

extension MoodActivityWidget: StaticHeightStackChidController {
    
    var height: CGFloat {
        return 108
    }
    
}

private extension MoodActivityWidget {
    
    func getTodayMood() -> Mood? {
        return moodService.fetchMood(date: Date.now.startOfDay)
    }
    
    func selectMoodButton(mood: Mood) {
        let animator = UIViewPropertyAnimator(duration: 0.25, dampingRatio: 1, animations: nil)
        
        view.isUserInteractionEnabled = false
        animator.addCompletion { _ in
            self.view.isUserInteractionEnabled = true
        }
        
        if let selectedMoodButton = moodButtons.first(where: { $0.isSelected }) {
            animator.addAnimations {
                selectedMoodButton.isSelected = false
            }
        }
        
        if let moodIndex = Mood.Kind.allCases.index(of: mood.kind),
           let moodButton = moodButtons.first(where: { $0.tag == moodIndex }) {
            animator.addAnimations {
                moodButton.isSelected = true
            }
        }
        
        animator.startAnimation()
    }
    
    func deselectAllMoodButtons() {
        moodButtons.forEach { $0.isSelected = false }
    }
    
}

final class MoodButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        adjustsImageWhenHighlighted = false
    }
    
    override var isSelected: Bool {
        didSet {
            transform = isSelected ? CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity
        }
    }
    
}
