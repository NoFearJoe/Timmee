//
//  HabitsCollectionAddHabitsManager.swift
//  Agile diary
//
//  Created by Илья Харабет on 17.05.2021.
//  Copyright © 2021 Mesterra. All rights reserved.
//

import UIKit

final class HabitsCollectionAddHabitsManager {
    
    // MARK: - State
    
    let sprintID: String
    let copyHabitsBeforeAdd: Bool
    let initiallyPickedHabits: [Habit]
    
    private(set) var pickedHabits: [Habit] = [] {
        didSet {
            updateAddHabitsButtonTitle()
            setAddHabitsButtonVisible(initiallyPickedHabits != pickedHabits, animated: true)
        }
    }
    
    var addHabits: (([Habit], @escaping () -> Void) -> Void)?
    var onAddHabits: (() -> Void)?
    
    private var isAddHabitsButtonVisible: Bool = true
    
    // MARK: - UI
    
    unowned var scrollView: UIScrollView!
    
    private let addHabitsButton = UIButton(type: .custom)
    
    // MARK: - Mathods
    
    init(sprintID: String, copyHabitsBeforeAdd: Bool, initiallyPickedHabits: [Habit]) {
        self.sprintID = sprintID
        self.copyHabitsBeforeAdd = copyHabitsBeforeAdd
        self.initiallyPickedHabits = initiallyPickedHabits
        self.pickedHabits = initiallyPickedHabits
    }
    
    func setupAddHabitsButton(view: UIView) {
        view.addSubview(addHabitsButton)
        view.bringSubviewToFront(addHabitsButton)
        addHabitsButton.addTarget(self, action: #selector(onTapToAddHabitsButton), for: .touchUpInside)
        addHabitsButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        addHabitsButton.setTitleColor(.white, for: .normal)
        addHabitsButton.layer.cornerRadius = 6
        addHabitsButton.clipsToBounds = true
        addHabitsButton.configureShadow(radius: 8, opacity: 0.1)
        
        // TODO: Add constraints for iPad
        [addHabitsButton.centerX()].toSuperview()
        addHabitsButton.height(52)
        if UIDevice.current.isIpad {
            addHabitsButton.width(360)
        } else {
            addHabitsButton.leading(16).toSuperview()
        }
        if #available(iOS 11.0, *) {
            addHabitsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        } else {
            addHabitsButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -16).isActive = true
        }
    }
    
    func add(habit: Habit) {
        pickedHabits.append(habit)
    }
    
    func remove(habit: Habit) {
        pickedHabits.remove(object: habit)
    }
    
    func setAddHabitsButtonVisible(_ visible: Bool, animated: Bool) {
        guard isAddHabitsButtonVisible != visible else { return }
        
        isAddHabitsButtonVisible = visible
        addHabitsButton.superview?.bringSubviewToFront(addHabitsButton)
        
        let animations = {
            let insetFromSafeArea: CGFloat = 52 + 16 + 36
            
            self.addHabitsButton.transform = visible ?
                .identity :
                CGAffineTransform(translationX: 0, y: insetFromSafeArea)
            
            self.scrollView?.contentInset.bottom = visible ? insetFromSafeArea : 0
        }
        
        if animated {
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: .curveEaseOut,
                           animations: animations,
                           completion: nil)
        } else {
            animations()
        }
    }
    
    func updateAddHabitsButtonTitle() {
        let diff = pickedHabits.count -  initiallyPickedHabits.count
        
        if diff >= 0 {
            addHabitsButton.setTitle(String.localizedAddNHabits(count: diff), for: .normal)
        } else {
            addHabitsButton.setTitle(String.localizedRemoveNHabits(count: abs(diff)), for: .normal)
        }
    }
    
    @objc private func onTapToAddHabitsButton() {
        let habitsToAdd: [Habit] = {
            if copyHabitsBeforeAdd {
                return pickedHabits.map { habit -> Habit in
                    let newHabit = habit.copy
                    newHabit.id = RandomStringGenerator.randomString(length: 24)
                    return newHabit
                }
            } else {
                return pickedHabits
            }
        }()
        
        if let addHabits = addHabits {
            addHabits(habitsToAdd) { [weak self] in
                self?.onAddHabits?()
            }
        } else {
            ServicesAssembly.shared.habitsService.addHabits(
                habitsToAdd,
                sprintID: sprintID,
                goalID: nil
            ) { [weak self] _ in
                self?.onAddHabits?()
            }
        }
    }
    
}
