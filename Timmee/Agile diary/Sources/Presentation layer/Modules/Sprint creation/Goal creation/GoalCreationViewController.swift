//
//  TargetCreationViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 15.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import UIComponents

enum GoalImportancy: Int {
    case low = 0
    case normal
    case high
    
    var title: String {
        switch self {
        case .low: return "importancy_low".localized
        case .normal: return "importancy_normal".localized
        case .high: return "importancy_high".localized
        }
    }
}

enum GoalAndHabitEditingMode {
    case full
    case short
}

final class GoalCreationViewController: BaseViewController, GoalProvider {
    
    @IBOutlet private var headerView: LargeHeaderView!
    @IBOutlet private var titleField: GrowingTextView!
    
    // MARK: - New UI
    
    private let stackViewController = StackViewController()
    
    private let noteSectionContainer = SectionContainer()
    private let noteField = GrowingTextView()
    
    private let habitsSectionContainer = SectionContainer()
    private let addHabitButton = UIButton()
    private let habitsTableView = AutoSizingTableView()
    
    private let stagesSectionContainer = SectionContainer()
    private let stagesView = GoalCreationStagesView()
    
    private let interactor = GoalCreationInteractor()
    
    private let goalsService = ServicesAssembly.shared.goalsService
    private let habitsService = ServicesAssembly.shared.habitsService
    
    private let stageCellActionsProvider = CellDeleteSwipeActionProvider()
    
    private lazy var habitsCacheAdapter = TableViewCacheAdapter(tableView: habitsTableView)
    private var habitsCacheObserver: CacheObserver<Habit>?
    private let habitCellActionsProvider = CellDeleteSwipeActionProvider()
    
    private let keyboardManager = KeyboardManager()
    private var contentScrollViewOffset: CGFloat = 0
    
    var goal: Goal!
    var sprintID: String!
    
    var editingMode: GoalAndHabitEditingMode = .full
    
    var isCreation: Bool = true
    
    func setGoal(_ goal: Goal?, sprintID: String) {
        self.goal = goal?.copy ?? interactor.createGoal()
        self.sprintID = sprintID
        self.isCreation = goal == nil
        
        if isCreation {
            goalsService.addGoal(self.goal, sprintID: sprintID) { _ in }
        }
    }
    
    func setEditingMode(_ mode: GoalAndHabitEditingMode) {
        self.editingMode = mode
    }
    
    override func prepare() {
        super.prepare()
        
        presentationController?.delegate = self
        
        interactor.output = self
        interactor.goalProvider = self
        setupDoneButton()
        setupTitleField()
        setupNoteField()
        setupAddHabitButton()
        setupKeyboardManager()
        
        stageCellActionsProvider.onDelete = { [unowned self] indexPath in
            self.interactor.removeStage(at: indexPath.row)
        }
        habitCellActionsProvider.onDelete = { [unowned self] indexPath in
            guard let habit = self.habitsCacheObserver?.item(at: indexPath) else { return }
            self.habitsService.removeHabit(habit, completion: { _ in })
            HabitsSchedulerService.shared.removeNotifications(for: habit, completion: {})
        }
                
        addChild(stackViewController)
        view.addSubview(stackViewController.view)
        [stackViewController.view.leading(), stackViewController.view.trailing(), stackViewController.view.bottom()].toSuperview()
        stackViewController.view.topToBottom().to(headerView, addTo: view)
        stackViewController.didMove(toParent: self)
        
        stackViewController.stackView.layoutMargins = UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 15)
        stackViewController.stackView.isLayoutMarginsRelativeArrangement = true
        
        stackViewController.stackView.spacing = 20
        
        stackViewController.setChild(noteSectionContainer, at: 0)
        
        noteSectionContainer.contentContainer.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        noteSectionContainer.configure(
            title: "note".localized,
            content: noteField
        )
        
        stackViewController.setChild(habitsSectionContainer, at: 1)
        
        habitsSectionContainer.configure(
            title: "habits".localized,
            content: habitsTableView,
            actionButton: addHabitButton
        )
        
        addHabitButton.height(28)
        addHabitButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        addHabitButton.addTarget(self, action: #selector(onAddHabit), for: .touchUpInside)
        
        habitsTableView.delegate = self
        habitsTableView.dataSource = self
        habitsTableView.separatorStyle = .singleLine
        habitsTableView.separatorColor = AppTheme.current.colors.decorationElementColor
        habitsTableView.separatorInset.left = 8
        habitsTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        habitsTableView.showsVerticalScrollIndicator = false
        if #available(iOS 11.0, *) {
            habitsTableView.contentInsetAdjustmentBehavior = .never
        }
        habitsTableView.register(
            ShortHabitCell.self,
            forCellReuseIdentifier: ShortHabitCell.reuseIdentifier
        )
        
        stackViewController.setChild(stagesSectionContainer, at: 2)
        
        stagesSectionContainer.contentContainer.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        stagesSectionContainer.configure(
            title: "stages".localized,
            content: stagesView,
            disclaimer: "stages_hint".localized
        )
        
        stagesView.onAddStage = { [unowned self] title in
            self.interactor.addStage(with: title)
        }
        stagesView.onReorder = { [unowned self] from, to in
            self.interactor.exchangeStages(at: (from.row, to.row))
        }
        
        stagesView.stagesTableView.delegate = self
        stagesView.stagesTableView.dataSource = self
    }
    
    override func refresh() {
        super.refresh()
        
        updateUI(goal: goal)
        reloadStages()
        setupHabitsCacheObserver(sprintID: sprintID)
        
        if titleField.textView.text.isEmpty {
            titleField.becomeFirstResponder()
        }
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        view.backgroundColor = AppTheme.current.colors.middlegroundColor
        stackViewController.view.backgroundColor = AppTheme.current.colors.middlegroundColor
        
        titleField.textView.textColor = AppTheme.current.colors.activeElementColor
        titleField.textView.font = AppTheme.current.fonts.bold(28)
        titleField.textView.keyboardAppearance = AppTheme.current.keyboardStyleForTheme
        
        noteField.textView.textColor = AppTheme.current.colors.activeElementColor
        noteField.textView.font = AppTheme.current.fonts.medium(17)
        noteField.textView.keyboardAppearance = AppTheme.current.keyboardStyleForTheme
        
        addHabitButton.layer.cornerRadius = 8
        addHabitButton.clipsToBounds = true
        addHabitButton.titleLabel?.font = AppTheme.current.fonts.medium(14)
        addHabitButton.adjustsImageWhenDisabled = false
        addHabitButton.backgroundColor = nil
        addHabitButton.setTitleColor(.white, for: .normal)
        addHabitButton.setTitleColor(UIColor.white.withAlphaComponent(0.85), for: .disabled)
        addHabitButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        addHabitButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor.withAlphaComponent(0.6)), for: .disabled)
        
        noteSectionContainer.setupAppearance()
        habitsSectionContainer.setupAppearance()
        stagesSectionContainer.setupAppearance()
        
        stagesView.setupAppearance()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !UserProperty.isGoalCreationOnboardingShown.bool() {
            UserProperty.isGoalCreationOnboardingShown.setBool(true)
            
            let onboardingController = GoalCreationOnboardingViewController()
            
            present(onboardingController, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? HabitCreationViewController {
            destination.setHabit(sender as? Habit, sprintID: sprintID, goalID: goal.id)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    @IBAction private func onAddHabit() {
        performSegue(withIdentifier: "ShowHabitCreation", sender: nil)
    }
    @IBAction private func onClose() {
        if isCreation {
            self.view.isUserInteractionEnabled = false
            goalsService.removeGoal(self.goal) { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction private func onDone() {
        updateTargetTitle()
        goalsService.updateGoal(goal, sprintID: sprintID, completion: { [weak self] success in
            guard success else { return }
            self?.dismiss(animated: true, completion: nil)
        })
    }
    
    @IBAction private func endEditing() {
        view.endEditing(true)
    }
    
}

extension GoalCreationViewController: GoalCreationInteractorOutput {
    
    func reloadStages() {
        stagesView.stagesTableView.reloadData()
    }
    
    func batchReloadStages(insertions: [Int] = [], deletions: [Int] = [], updates: [Int] = []) {
        UIView.performWithoutAnimation {
            self.stagesView.stagesTableView.beginUpdates()
            
            deletions.forEach { index in
                self.stagesView.stagesTableView.deleteRows(at: [IndexPath(row: index, section: 0)],
                                                           with: .none)
            }
            
            insertions.forEach { index in
                self.stagesView.stagesTableView.insertRows(at: [IndexPath(row: index, section: 0)],
                                                           with: .none)
            }
            
            updates.forEach { index in
                self.stagesView.stagesTableView.reloadRows(at: [IndexPath(row: index, section: 0)],
                                                           with: .none)
            }
            
            self.stagesView.stagesTableView.endUpdates()
        }
    }
    
    func stagesInserted(at indexes: [Int]) {
        batchReloadStages(insertions: indexes)
    }
    
    func stagesUpdated(at indexes: [Int]) {
        batchReloadStages(updates: indexes)
    }
    
    func stagesRemoved(at indexes: [Int]) {
        reloadStages()
    }
    
}

extension GoalCreationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case habitsTableView: return habitsCacheObserver?.numberOfItems(in: section) ?? 0
        case stagesView.stagesTableView: return interactor.stagesCount()
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case habitsTableView:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ShortHabitCell.reuseIdentifier,
                for: indexPath
            ) as! ShortHabitCell
            
            if let habit = habitsCacheObserver?.item(at: indexPath) {
                cell.configure(habit: habit)
                cell.delegate = habitCellActionsProvider
            }
            return cell
        case stagesView.stagesTableView:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: GoalCreationStageCell.reuseIdentifier,
                for: indexPath
            ) as! GoalCreationStageCell
            
            if let stage = interactor.stage(at: indexPath.row) {
                cell.title = stage.title
                cell.stageNumber = indexPath.row + 1
                
                cell.onChangeTitle = { [unowned self, unowned cell] title in
                    guard let actualIndexPath = tableView.indexPath(for: cell) else { return }
                    self.interactor.updateStage(at: actualIndexPath.row, newTitle: title)
                }
                cell.onChangeHeight = { [unowned self] height in
                    UIView.performWithoutAnimation {
                        self.stagesView.stagesTableView.beginUpdates()
                        self.stagesView.stagesTableView.endUpdates()
                    }
                }
                
                cell.delegate = stageCellActionsProvider
                
                cell.applyAppearance()
            }
            
            return cell
        default: return UITableViewCell()
        }
    }
    
}

extension GoalCreationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case habitsTableView:
            guard let habit = habitsCacheObserver?.item(at: indexPath) else { return }
            performSegue(withIdentifier: "ShowHabitCreation", sender: habit)
        default: return
        }
    }
    
}

extension GoalCreationViewController: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        titleField.setContentOffset(.zero, animated: true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            endEditing()
            return false
        }
        return true
    }
    
}

extension GoalCreationViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == stackViewController.view || touch.view == stackViewController.stackView
    }
    
}

extension GoalCreationViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        guard isCreation else { return }
        
        goalsService.removeGoal(self.goal, completion: { _ in })
    }
    
}

private extension GoalCreationViewController {
 
    func updateUI(goal: Goal) {
        titleField.textView.text = goal.title
        noteField.textView.text = goal.note
        updateDoneButtonState()
    }
    
    func updateTargetTitle() {
        goal.title = getTargetTitle()
    }
    
    func updateTargetNote() {
        goal.note = getTargetNote()
    }
    
    func setupDoneButton() {
        headerView.rightButton?.setTitleColor(AppTheme.current.colors.inactiveElementColor, for: .disabled)
        headerView.rightButton?.setTitleColor(AppTheme.current.colors.mainElementColor, for: .normal)
    }
    
    func updateDoneButtonState() {
        headerView.rightButton?.isEnabled = !goal.title.isEmpty
    }
    
}

private extension GoalCreationViewController {
    
    func setupHabitsCacheObserver(sprintID: String) {
        habitsCacheObserver = habitsService.habitsByGoalObserver(sprintID: sprintID, goalID: goal.id)
        habitsCacheObserver?.setSubscriber(habitsCacheAdapter)
        habitsCacheObserver?.setActions(
            onInitialFetch: nil,
            onItemsCountChange: { [weak self] count in
                self?.habitsSectionContainer.contentContainer.isHidden = count == 0
            },
            onItemChange: nil,
            onBatchUpdatesStarted: nil,
            onBatchUpdatesCompleted: nil
        )
        habitsCacheObserver?.fetchInitialEntities()
    }
    
    func setupAddHabitButton() {
        addHabitButton.setTitle("add".localized, for: .normal)
    }
    
}

private extension GoalCreationViewController {
    
    func setupTitleField() {
        titleField.textView.delegate = self
        titleField.textView.textContainerInset = UIEdgeInsets(top: 3, left: -2, bottom: -1, right: 0)
        titleField.maxNumberOfLines = 5
        titleField.showsVerticalScrollIndicator = false
        titleField.placeholderAttributedText
            = NSAttributedString(string: "goal_title_placeholder".localized,
                                 attributes: [.font: AppTheme.current.fonts.bold(28),
                                              .foregroundColor: AppTheme.current.colors.inactiveElementColor])
        
        setupTitleObserver()
    }
    
    func setupTitleObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(goalTitleDidChange),
                                               name: UITextView.textDidChangeNotification,
                                               object: titleField.textView)
    }
    
    @objc func goalTitleDidChange(notification: Notification) {
        updateTargetTitle()
        updateDoneButtonState()
    }
    
    func getTargetTitle() -> String {
        return titleField.textView.text.trimmed
    }
    
}

private extension GoalCreationViewController {
    
    func setupNoteField() {
        noteField.textView.delegate = self
        noteField.textView.textContainerInset = UIEdgeInsets(top: 3, left: -4, bottom: -1, right: 0)
        noteField.maxNumberOfLines = 100
        noteField.showsVerticalScrollIndicator = false
        noteField.showsHorizontalScrollIndicator = false
        noteField.placeholderAttributedText
            = NSAttributedString(string: "goal_note_placeholder".localized,
                                 attributes: [.font: AppTheme.current.fonts.medium(17),
                                              .foregroundColor: AppTheme.current.colors.inactiveElementColor])
        
        setupNoteObserver()
    }
    
    func setupNoteObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(goalNoteDidChange),
                                               name: UITextView.textDidChangeNotification,
                                               object: noteField.textView)
    }
    
    @objc func goalNoteDidChange(notification: Notification) {
        updateTargetNote()
    }
    
    func getTargetNote() -> String {
        return noteField.textView.text.trimmed
    }
    
}

private extension GoalCreationViewController {
    
    func setupKeyboardManager() {
        keyboardManager.keyboardWillAppear = { [unowned self] frame, duration in
            UIView.animate(withDuration: duration) {
                let offset = self.calculateTargetScrollViewYOffset(keyboardFrame: frame)
                self.contentScrollViewOffset = offset
                self.stackViewController.scrollView.contentOffset.y += offset
            }
        }
        
        keyboardManager.keyboardWillDisappear = { [unowned self] frame, duration in
            UIView.animate(withDuration: duration) {
                self.stackViewController.scrollView.contentOffset.y -= self.contentScrollViewOffset
                self.contentScrollViewOffset = 0
            }
        }
    }
    
    func calculateTargetScrollViewYOffset(keyboardFrame: CGRect) -> CGFloat {
        guard let focusedView = stackViewController.stackView.currentFirstResponder() as? UIView else { return 0 }
        let convertedFocusedViewFrame = view.convert(focusedView.frame, from: focusedView)
        return max(0, convertedFocusedViewFrame.maxY - keyboardFrame.minY)
    }
    
}
