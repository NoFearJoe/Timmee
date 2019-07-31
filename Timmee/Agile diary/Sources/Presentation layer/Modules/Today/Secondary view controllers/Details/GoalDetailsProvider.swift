//
//  GoalDetailsProvider.swift
//  Agile diary
//
//  Created by i.kharabet on 16/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIComponents

final class GoalDetailsProvider: DetailModuleProvider {
    
    var onEdit: (() -> Void)?
    var onAddDiaryEntry: (() -> Void)?
    
    weak var holderViewController: UIViewController?
    
    private let goal: Goal
    
    private let goalsService = ServicesAssembly.shared.goalsService
    private let stagesService = ServicesAssembly.shared.subtasksService
    
    init(goal: Goal) {
        self.goal = goal
    }
    
    func loadContent(completion: @escaping (Error?) -> Void) {
        completion(nil)
    }
    
    func reloadContent() {
        let contentView = stackViewContainer
        
        // Stages
        let stages = goal.stages.sorted(by: { $0.sortPosition < $1.sortPosition })
        if !stages.isEmpty {
            let emptyView = UIView()
            emptyView.backgroundColor = AppTheme.current.colors.foregroundColor
            emptyView.heightAnchor.constraint(equalToConstant: 20).isActive = true
            contentView.addView(emptyView)
            
            let stagesContainerView = UIView()
            for (index, stage) in stages.enumerated() {
                let stageView = StageView.loadedFromNib()
                stageView.title = stage.title
                stageView.isChecked = stage.isDone
                stageView.setupAppearance()
                stageView.onChangeCheckedState = { [unowned self] isChecked in
                    stage.isDone = isChecked
                    self.stagesService.updateSubtask(stage, completion: nil)
                }
                stagesContainerView.addSubview(stageView)
                if stages.count == 1 {
                    stageView.allEdges().toSuperview()
                } else if index == 0 {
                    [stageView.top(4), stageView.leading(), stageView.trailing()].toSuperview()
                } else if index >= stages.count - 1 {
                    [stageView.leading(), stageView.trailing(), stageView.bottom(4)].toSuperview()
                    let previousView = stagesContainerView.subviews[index - 1]
                    stageView.topToBottom().to(previousView, addTo: stagesContainerView)
                } else {
                    [stageView.leading(), stageView.trailing()].toSuperview()
                    let previousView = stagesContainerView.subviews[index - 1]
                    stageView.topToBottom().to(previousView, addTo: stagesContainerView)
                }
            }
            let stagesContainer = DetailView(title: "stages".localized, detailView: stagesContainerView)
            stagesContainer.titleLabel.font = AppTheme.current.fonts.regular(14)
            stagesContainer.titleLabel.textColor = AppTheme.current.colors.inactiveElementColor
            contentView.addView(stagesContainer)
        }
        
        // Buttons
        let emptyView5 = UIView()
        emptyView5.backgroundColor = AppTheme.current.colors.foregroundColor
        emptyView5.heightAnchor.constraint(equalToConstant: 20).isActive = true
        contentView.addView(emptyView5)
        
        let buttonsContainer = UIStackView()
        buttonsContainer.axis = .horizontal
        buttonsContainer.distribution = .fillEqually
        buttonsContainer.spacing = 15
        buttonsContainer.backgroundColor = .clear
        let editButton = UIButton(type: .custom)
        editButton.addTarget(self, action: #selector(onTapToEditButton), for: .touchUpInside)
        editButton.height(52)
        editButton.setTitle("edit".localized, for: .normal)
        editButton.titleLabel?.font = AppTheme.current.fonts.medium(20)
        editButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.inactiveElementColor), for: .normal)
        editButton.setTitleColor(.white, for: .normal)
        editButton.clipsToBounds = true
        editButton.layer.cornerRadius = 6
        buttonsContainer.addArrangedSubview(editButton)
        
        if goal.isDone {
            let restoreButton = UIButton(type: .custom)
            restoreButton.addTarget(self, action: #selector(onTapToRestoreButton), for: .touchUpInside)
            restoreButton.setTitle("restore".localized, for: .normal)
            restoreButton.titleLabel?.font = AppTheme.current.fonts.medium(20)
            restoreButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
            restoreButton.setTitleColor(.white, for: .normal)
            restoreButton.clipsToBounds = true
            restoreButton.layer.cornerRadius = 6
            buttonsContainer.addArrangedSubview(restoreButton)
        } else {
            let completeButton = UIButton(type: .custom)
            completeButton.addTarget(self, action: #selector(onTapToCompleteButton), for: .touchUpInside)
            completeButton.setTitle("complete".localized, for: .normal)
            completeButton.titleLabel?.font = AppTheme.current.fonts.medium(20)
            completeButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
            completeButton.setTitleColor(.white, for: .normal)
            completeButton.clipsToBounds = true
            completeButton.layer.cornerRadius = 6
            buttonsContainer.addArrangedSubview(completeButton)
        }
        contentView.addView(buttonsContainer)
        
        // Diary
        
        let emptyView6 = UIView()
        emptyView6.backgroundColor = AppTheme.current.colors.foregroundColor
        emptyView6.height(20)
        contentView.addView(emptyView6)
        
        let diaryView = DiaryEntriesSubmoduleView(maxEntriesCount: 5)
        diaryView.onAddEntry = { [unowned self] in
            self.onAddDiaryEntry?()
        }
        diaryView.configure(attachmentType: .goal, entity: goal)
        let diaryContainer = DetailView(title: "diary".localized, detailView: diaryView)
        diaryContainer.clipsToBounds = false
        diaryContainer.titleLabel.font = AppTheme.current.fonts.regular(14)
        diaryContainer.titleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        contentView.addView(diaryContainer)
        
        // Last empty view
        
        let emptyViewLast = UIView()
        emptyViewLast.backgroundColor = AppTheme.current.colors.foregroundColor
        emptyViewLast.heightAnchor.constraint(equalToConstant: 20).isActive = true
        contentView.addView(emptyViewLast)
    }
    
    lazy var header: UIViewController & VerticalCompressibleViewContainer = {
        let container = CompressibleViewContainerController()
        container.compressibleViewContainer.backgroundView.backgroundColor = AppTheme.current.colors.foregroundColor
        
        let topSpacer = CompressibleEmptyView()
        topSpacer.configure(with: CompressibleEmptyView.Model(backgroundColor: AppTheme.current.colors.foregroundColor,
                                                              maximizedStateHeight: 20,
                                                              minimizedStateHeight: 8,
                                                              reversed: false))
        container.add(compressibleView: topSpacer)
        
        // Status
        
        if goal.isDone {
            let statusView = CompressibleTitleView.loadedFromNib()
            statusView.backgroundColor = AppTheme.current.colors.foregroundColor
            let attributedStatus = NSAttributedString(string: "complete".localized,
                                                      attributes: [.foregroundColor: AppTheme.current.colors.mainElementColor])
            statusView.configure(with: CompressibleTitleView.Model(attributedText: attributedStatus,
                                                                   transparentDisappearing: false,
                                                                   minimumHeight: 0,
                                                                   sideInset: 15,
                                                                   defaultFont: AppTheme.current.fonts.medium(16),
                                                                   minimumFont: AppTheme.current.fonts.medium(12),
                                                                   compressionDisabled: false))
            container.add(compressibleView: statusView)
            
            let middleSpacer = CompressibleEmptyView()
            middleSpacer.configure(with: CompressibleEmptyView.Model(backgroundColor: AppTheme.current.colors.foregroundColor,
                                                                     maximizedStateHeight: 4,
                                                                     minimizedStateHeight: 2,
                                                                     reversed: false))
            container.add(compressibleView: middleSpacer)
        }
        
        // Title
        
        let titleView = CompressibleTitleView.loadedFromNib()
        titleView.backgroundColor = AppTheme.current.colors.foregroundColor
        let attributedTitle = NSAttributedString(string: goal.title,
                                                 attributes: [.foregroundColor: AppTheme.current.colors.activeElementColor])
        titleView.configure(with: CompressibleTitleView.Model(attributedText: attributedTitle,
                                                              transparentDisappearing: false,
                                                              minimumHeight: 32,
                                                              sideInset: 15,
                                                              defaultFont: AppTheme.current.fonts.bold(34),
                                                              minimumFont: AppTheme.current.fonts.bold(24)))
        container.add(compressibleView: titleView)
        
        if !goal.note.isEmpty {
            // Middle spacer

            let middleSpacer = CompressibleEmptyView()
            middleSpacer.configure(with: CompressibleEmptyView.Model(backgroundColor: AppTheme.current.colors.foregroundColor,
                                                                     maximizedStateHeight: 4,
                                                                     minimizedStateHeight: 0,
                                                                     reversed: false))
            container.add(compressibleView: middleSpacer)
            
            // Subtitle
            
            let subtitleView = CompressibleTitleView.loadedFromNib()
            subtitleView.backgroundColor = AppTheme.current.colors.foregroundColor
            let attributedSubtitle = NSAttributedString(string: goal.note,
                                                        attributes: [.foregroundColor: AppTheme.current.colors.activeElementColor])
            subtitleView.configure(with: CompressibleTitleView.Model(attributedText: attributedSubtitle,
                                                                     transparentDisappearing: true,
                                                                     minimumHeight: 0,
                                                                     sideInset: 15,
                                                                     defaultFont: AppTheme.current.fonts.regular(18),
                                                                     minimumFont: AppTheme.current.fonts.regular(0),
                                                                     compressionDisabled: false))
            container.add(compressibleView: subtitleView)
        }
        
        let bottomSpacer = CompressibleEmptyView()
        bottomSpacer.configure(with: CompressibleEmptyView.Model(backgroundColor: AppTheme.current.colors.foregroundColor,
                                                                 maximizedStateHeight: 20,
                                                                 minimizedStateHeight: 8,
                                                                 reversed: false))
        container.add(compressibleView: bottomSpacer)
        
        let separator = CompressibleEmptyView()
        separator.configure(with: CompressibleEmptyView.Model(backgroundColor: AppTheme.current.colors.decorationElementColor,
                                                              maximizedStateHeight: 1,
                                                              minimizedStateHeight: 1,
                                                              reversed: false))
        container.add(compressibleView: separator)
        
        return container
    }()
    
    lazy var stackViewContainer: UIScrollView & ITCSStackViewContainer = TCSStackViewContainer.loadedFromNib()
    
    var cachedHeaderDataAvailable: Bool {
        return true
    }
    
    var cachedContentDataAvailable: Bool {
        return true
    }
    
    lazy var fullPlaceholder: UIView & AnimatableView = {
        let skeletView = DetailsFullPlaceholderDefault.loadedFromNib()
        let placeholderView = SkeletonAnimatableView(skeletView: skeletView, animationKey: "ak")
        placeholderView.backgroundColor = AppTheme.current.colors.foregroundColor
        return placeholderView
    }()
    
    lazy var contentPlaceholder: UIView & AnimatableView = {
        let skeletView = DetailsContentPlaceholderDefault.loadedFromNib()
        let placeholderView = SkeletonAnimatableView(skeletView: skeletView, animationKey: "ak")
        placeholderView.backgroundColor = AppTheme.current.colors.foregroundColor
        return placeholderView
    }()
    
    var viewConfiguration: DetailsContentViewConfiguration {
        return .init(bottomBackgroundColor: AppTheme.current.colors.foregroundColor,
                     errorPlaceholderTextColor: AppTheme.current.colors.activeElementColor)
    }
    
    // Actions
    
    @objc private func onTapToEditButton() {
        onEdit?()
    }
    
    @objc private func onTapToCompleteButton() {
        goal.isDone = true
        goalsService.updateGoal(goal, completion: { [weak self] _ in
            self?.holderViewController?.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc private func onTapToRestoreButton() {
        goal.isDone = false
        goalsService.updateGoal(goal, completion: { [weak self] _ in
            self?.holderViewController?.dismiss(animated: true, completion: nil)
        })
    }
    
}
