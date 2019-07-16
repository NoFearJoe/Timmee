//
//  HabitDetailsProvider.swift
//  Agile diary
//
//  Created by i.kharabet on 15/07/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIComponents

final class HabitDetailsProvider: DetailModuleProvider {
    
    var onEdit: (() -> Void)?
    
    weak var holderViewController: UIViewController?
    
    private let habit: Habit
    
    private let habitsService = ServicesAssembly.shared.habitsService
    
    init(habit: Habit) {
        self.habit = habit
    }
    
    func loadContent(completion: @escaping (Error?) -> Void) {
        completion(nil)
    }
    
    func reloadContent() {
        let contentView = stackViewContainer
        
        // value and time
        
        if let value = habit.value {
            let emptyView0 = UIView()
            emptyView0.backgroundColor = AppTheme.current.colors.foregroundColor
            emptyView0.heightAnchor.constraint(equalToConstant: 20).isActive = true
            contentView.addView(emptyView0)
            
            let amountLabel = UILabel()
            amountLabel.font = AppTheme.current.fonts.regular(24)
            amountLabel.textColor = AppTheme.current.colors.activeElementColor
            amountLabel.text = "\(value.amount)" + " " + value.units.localized
            let amountContainer = DetailView(title: "amount".localized, detailView: amountLabel)
            amountContainer.titleLabel.font = AppTheme.current.fonts.regular(14)
            amountContainer.titleLabel.textColor = AppTheme.current.colors.inactiveElementColor
            contentView.addView(amountContainer)
        }
        
        let emptyView1 = UIView()
        emptyView1.backgroundColor = AppTheme.current.colors.foregroundColor
        emptyView1.heightAnchor.constraint(equalToConstant: 20).isActive = true
        contentView.addView(emptyView1)
        
        let dayTimeLabel = UILabel()
        dayTimeLabel.font = AppTheme.current.fonts.regular(24)
        dayTimeLabel.textColor = AppTheme.current.colors.activeElementColor
        dayTimeLabel.text = habit.calculatedDayTime.localized.capitalizedFirst
        let dayTimeContainer = DetailView(title: "day_time".localized, detailView: dayTimeLabel)
        dayTimeContainer.titleLabel.font = AppTheme.current.fonts.regular(14)
        dayTimeContainer.titleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        contentView.addView(dayTimeContainer)
        
        // reminder
        if let notificationDate = habit.notificationDate {
            let emptyView2 = UIView()
            emptyView2.backgroundColor = AppTheme.current.colors.foregroundColor
            emptyView2.heightAnchor.constraint(equalToConstant: 20).isActive = true
            contentView.addView(emptyView2)
            
            let reminderLabel = UILabel()
            reminderLabel.font = AppTheme.current.fonts.regular(24)
            reminderLabel.textColor = AppTheme.current.colors.activeElementColor
            reminderLabel.text = notificationDate.asTimeString
            let notificationContainer = DetailView(title: "reminder".localized, detailView: reminderLabel)
            notificationContainer.titleLabel.font = AppTheme.current.fonts.regular(14)
            notificationContainer.titleLabel.textColor = AppTheme.current.colors.inactiveElementColor
            contentView.addView(notificationContainer)
        }
        
        // days
        
        let emptyView3 = UIView()
        emptyView3.backgroundColor = AppTheme.current.colors.foregroundColor
        emptyView3.heightAnchor.constraint(equalToConstant: 20).isActive = true
        contentView.addView(emptyView3)
        
        let daysContainerView = UIStackView()
        daysContainerView.axis = .horizontal
        daysContainerView.alignment = .leading
        daysContainerView.distribution = .fill
        daysContainerView.spacing = 8
        daysContainerView.height(36)
        daysContainerView.width(CGFloat(habit.dueDays.count) * 36 + CGFloat(habit.dueDays.count - 1) * 8)
        habit.dueDays.sorted(by: { $0.weekday < $1.weekday }).forEach { dueDay in
            let dueDayView = UILabel()
            dueDayView.text = dueDay.localizedShort
            dueDayView.textColor = AppTheme.current.colors.foregroundColor
            dueDayView.font = AppTheme.current.fonts.regular(16)
            dueDayView.textAlignment = .center
            dueDayView.clipsToBounds = true
            dueDayView.layer.cornerRadius = 18
            if dueDay.weekday > 5 {
                dueDayView.backgroundColor = AppTheme.current.colors.wrongElementColor
            } else {
                dueDayView.backgroundColor = AppTheme.current.colors.mainElementColor
            }
            dueDayView.height(36)
            dueDayView.width(36)
            daysContainerView.addArrangedSubview(dueDayView)
        }
        let daysWrapperView = UIView()
        daysWrapperView.backgroundColor = .clear
        daysWrapperView.height(44)
        daysWrapperView.addSubview(daysContainerView)
        [daysContainerView.top(4), daysContainerView.leading(), daysContainerView.bottom(4)].toSuperview()
        let daysContainer = DetailView(title: "due_days".localized, detailView: daysWrapperView)
        daysContainer.titleLabel.font = AppTheme.current.fonts.regular(14)
        daysContainer.titleLabel.textColor = AppTheme.current.colors.inactiveElementColor
        contentView.addView(daysContainer)
        
        // link
        if !habit.link.trimmed.isEmpty {
            let emptyView4 = UIView()
            emptyView4.backgroundColor = AppTheme.current.colors.foregroundColor
            emptyView4.heightAnchor.constraint(equalToConstant: 20).isActive = true
            contentView.addView(emptyView4)
            
            let linkLabel = UILabel()
            linkLabel.font = AppTheme.current.fonts.regular(16)
            linkLabel.numberOfLines = 2
            let linkString = NSAttributedString(string: habit.link,
                                                attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                                                             .foregroundColor: AppTheme.current.colors.mainElementColor])
            linkLabel.attributedText = linkString
            linkLabel.isUserInteractionEnabled = true
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapToLink))
            linkLabel.addGestureRecognizer(tapGestureRecognizer)
            let linkContainer = DetailView(title: "link".localized, detailView: linkLabel)
            linkContainer.titleLabel.font = AppTheme.current.fonts.regular(14)
            linkContainer.titleLabel.textColor = AppTheme.current.colors.inactiveElementColor
            contentView.addView(linkContainer)
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
        
        if habit.isDone(at: Date.now) {
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
        
        let titleView = CompressibleTitleView.loadedFromNib()
        titleView.backgroundColor = AppTheme.current.colors.foregroundColor
        let attributedTitle = NSAttributedString(string: habit.title,
                                                 attributes: [.foregroundColor: AppTheme.current.colors.activeElementColor])
        titleView.configure(with: CompressibleTitleView.Model(attributedText: attributedTitle,
                                                              transparentDisappearing: false,
                                                              minimumHeight: 32,
                                                              sideInset: 15,
                                                              defaultFont: AppTheme.current.fonts.bold(34),
                                                              minimumFont: AppTheme.current.fonts.bold(24)))
        container.add(compressibleView: titleView)
        
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
    
    @objc private func onTapToLink() {
        guard let url = URL(string: habit.link), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @objc private func onTapToEditButton() {
        onEdit?()
    }
    
    @objc private func onTapToCompleteButton() {
        habit.setDone(true, at: Date.now)
        habitsService.updateHabit(habit, completion: { [weak self] _ in
            self?.holderViewController?.dismiss(animated: true, completion: nil)
        })
    }
    
    @objc private func onTapToRestoreButton() {
        habit.setDone(false, at: Date.now)
        habitsService.updateHabit(habit, completion: { [weak self] _ in
            self?.holderViewController?.dismiss(animated: true, completion: nil)
        })
    }
    
}