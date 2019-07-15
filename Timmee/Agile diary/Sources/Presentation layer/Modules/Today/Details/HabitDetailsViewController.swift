//
//  HabitDetailsViewController.swift
//  Agile diary
//
//  Created by Илья Харабет on 27/06/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit

final class HabitDetailsViewController: UIViewController {
    
    let habit: Habit
    
    var onEdit: (() -> Void)?
    
    @IBOutlet private var headerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    
    @IBOutlet private var contentView: UIStackView!
    
    @IBOutlet private var buttonsContainer: UIView!
    @IBOutlet private var editButton: UIButton!
    @IBOutlet private var completeButton: UIButton!
    
    private let habitsService = ServicesAssembly.shared.habitsService
    
    init(habit: Habit) {
        self.habit = habit
        super.init(nibName: "HabitDetailsViewController", bundle: nil)
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
    
    @objc private func onTapToLink() {
        guard let url = URL(string: habit.link), UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction private func onTapToEditButton() {
        onEdit?()
    }
    
    @IBAction private func onTapToCompleteButton() {
        habit.setDone(true, at: Date.now)
        habitsService.updateHabit(habit, completion: { [weak self] _ in
            self?.completeButton.isEnabled = false
        })
    }
    
    private func reloadUI() {
        titleLabel.text = habit.title
        
        let mainAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: AppTheme.current.colors.mainElementColor]
        
        // value and time
        let amountAndTimeLabel = UILabel()
        amountAndTimeLabel.font = AppTheme.current.fonts.regular(24)
        amountAndTimeLabel.textColor = AppTheme.current.colors.inactiveElementColor
        let amountAndTimeString = NSMutableAttributedString()
        if let value = habit.value {
            let amountString = NSAttributedString(string: "\(value.amount)", attributes: mainAttributes)
            let spaceString = NSAttributedString(string: " ")
            let unitString = NSAttributedString(string: value.units.localized)
            let commaString = NSAttributedString(string: ", ")
            amountAndTimeString.append(amountString)
            amountAndTimeString.append(spaceString)
            amountAndTimeString.append(unitString)
            amountAndTimeString.append(commaString)
        }
        let dayTime = habit.value == nil ? habit.calculatedDayTime.localizedAt.capitalizedFirst : habit.calculatedDayTime.localizedAt.lowercased()
        let dayTimeString = NSAttributedString(string: dayTime, attributes: mainAttributes)
        amountAndTimeString.append(dayTimeString)
        amountAndTimeLabel.attributedText = amountAndTimeString
        contentView.addArrangedSubview(amountAndTimeLabel)
        
        // reminder
        if let notificationDate = habit.notificationDate {
            let reminderLabel = UILabel()
            reminderLabel.font = AppTheme.current.fonts.regular(24)
            reminderLabel.textColor = AppTheme.current.colors.inactiveElementColor
            let reminderString = NSMutableAttributedString(string: "reminder".localized + ": ")
            reminderString.append(NSAttributedString(string: notificationDate.asTimeString, attributes: mainAttributes))
            reminderLabel.attributedText = reminderString
            contentView.addArrangedSubview(reminderLabel)
        }
        
        // days
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
        daysWrapperView.height(36)
        daysWrapperView.addSubview(daysContainerView)
        [daysContainerView.top(), daysContainerView.leading(), daysContainerView.bottom()].toSuperview()
        contentView.addArrangedSubview(daysWrapperView)
        
        // link
        if !habit.link.trimmed.isEmpty {
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
            contentView.addArrangedSubview(linkLabel)
        }
        
        completeButton.isEnabled = !habit.isDone(at: Date.now)
    }
    
    private func setupAppearance() {
        view.backgroundColor = AppTheme.current.colors.foregroundColor
        
        titleLabel.textColor = AppTheme.current.colors.activeElementColor
        titleLabel.font = AppTheme.current.fonts.bold(44)
        
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
