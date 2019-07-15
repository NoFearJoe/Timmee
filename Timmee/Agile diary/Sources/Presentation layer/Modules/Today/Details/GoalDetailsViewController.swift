//
//  GoalDetailsViewController.swift
//  Agile diary
//
//  Created by Илья Харабет on 08/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class GoalDetailsViewController: UIViewController {
    
    let goal: Goal
    
    var onEdit: (() -> Void)?
    
    @IBOutlet private var headerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var noteLabel: UILabel!
    
    @IBOutlet private(set) var contentScrollView: UIScrollView!
    @IBOutlet private var contentView: UIView!
    
    @IBOutlet private var buttonsContainer: UIView!
    @IBOutlet private var editButton: UIButton!
    @IBOutlet private var completeButton: UIButton!
    
    private let goalsService = ServicesAssembly.shared.goalsService
    private let stagesService = ServicesAssembly.shared.subtasksService
    
    init(goal: Goal) {
        self.goal = goal
        super.init(nibName: "GoalDetailsViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        setupAppearance()
        reloadUI()
        
        editButton.setTitle("edit".localized, for: .normal)
        completeButton.setTitle("complete".localized, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAppearance()
    }
    
    @IBAction private func onTapToEditButton() {
        onEdit?()
    }
    
    @IBAction private func onTapToCompleteButton() {
        goal.isDone = true
        goalsService.updateGoal(goal) { [weak self] _ in
            self?.completeButton.isEnabled = false
        }
    }
    
    private func reloadUI() {
        titleLabel.text = goal.title
        noteLabel.text = goal.note
        
        addStageViews(goal: goal)
    }
    
    private func addStageViews(goal: Goal) {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let stages = goal.stages.sorted(by: { $0.sortPosition < $1.sortPosition })
        for (index, stage) in stages.enumerated() {
            let stageView = StageView.loadedFromNib()
            stageView.title = stage.title
            stageView.isChecked = stage.isDone
            stageView.setupAppearance()
            stageView.onChangeCheckedState = { [unowned self] isChecked in
                stage.isDone = isChecked
                self.stagesService.updateSubtask(stage, completion: nil)
            }
            contentView.addSubview(stageView)
            if stages.count == 1 {
                stageView.allEdges().toSuperview()
            } else if index == 0 {
                [stageView.top(), stageView.leading(), stageView.trailing()].toSuperview()
            } else if index >= stages.count - 1 {
                [stageView.leading(), stageView.trailing(), stageView.bottom()].toSuperview()
                let previousView = contentView.subviews[index - 1]
                stageView.topToBottom().to(previousView, addTo: contentView)
            } else {
                [stageView.leading(), stageView.trailing()].toSuperview()
                let previousView = contentView.subviews[index - 1]
                stageView.topToBottom().to(previousView, addTo: contentView)
            }
        }
    }
    
    private func setupAppearance() {
        view.backgroundColor = AppTheme.current.colors.foregroundColor
        
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        titleLabel.font = AppTheme.current.fonts.bold(44)
        
        noteLabel.textColor = AppTheme.current.colors.activeElementColor
        noteLabel.font = AppTheme.current.fonts.regular(20)
        
        editButton.titleLabel?.font = AppTheme.current.fonts.medium(20)
        editButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.inactiveElementColor), for: .normal)
        editButton.setTitleColor(.white, for: .normal)
        editButton.clipsToBounds = true
        editButton.layer.cornerRadius = 6
        completeButton.titleLabel?.font = AppTheme.current.fonts.medium(20)
        completeButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        completeButton.setTitleColor(.white, for: .normal)
        completeButton.clipsToBounds = true
        completeButton.layer.cornerRadius = 6
    }
    
}
