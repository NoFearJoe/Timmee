//
//  TargetCreationViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 15.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit
import UIComponents

enum TargetImportancy: Int {
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

enum TargetAndHabitEditingMode {
    case full
    case short
}

final class TargetCreationViewController: BaseViewController, GoalProvider, HintViewTrait {
    
    @IBOutlet private var contentScrollView: UIScrollView!
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var headerView: LargeHeaderView!
    @IBOutlet private var titleField: GrowingTextView!
    @IBOutlet private var stagesTitleLabel: UILabel!
    @IBOutlet private var stagesHintButton: UIButton!
    @IBOutlet private var stageTextField: UITextField!
    @IBOutlet private var addStageButton: UIButton!
    @IBOutlet private var stagesTableView: ReorderableTableView!
    @IBOutlet private var stagesTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var stagesTableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private var noteTitleLabel: UILabel!
    @IBOutlet private var noteField: GrowingTextView!
    @IBOutlet private var cardViews: [CardView]!
    
    var hintPopover: HintPopoverView? {
        didSet {
            hintPopover?.roundedView.backgroundColor = AppTheme.current.colors.backgroundColor
            hintPopover?.textLabel?.textColor = AppTheme.current.colors.activeElementColor
            hintPopover?.triangleView.tintColor = AppTheme.current.colors.backgroundColor
            hintPopover?.willCloseBlock = {
                self.stagesHintButton.isSelected = false
                self.stagesHintButton.isUserInteractionEnabled = false
            }
            hintPopover?.didCloseBlock = { self.stagesHintButton.isUserInteractionEnabled = true }
        }
    }
    
    private let interactor = TargetCreationInteractor()
    private let goalsService = ServicesAssembly.shared.goalsService
    private let stageCellActionsProvider = CellDeleteSwipeActionProvider()
    
    private let keyboardManager = KeyboardManager()
    private var contentScrollViewOffset: CGFloat = 0
    
    var goal: Goal!
    var sprintID: String!
    
    var editingMode: TargetAndHabitEditingMode = .full
    
    func setGoal(_ goal: Goal?, sprintID: String) {
        self.goal = goal?.copy ?? interactor.createGoal()
        self.sprintID = sprintID
    }
    
    func setEditingMode(_ mode: TargetAndHabitEditingMode) {
        self.editingMode = mode
    }
    
    override func prepare() {
        super.prepare()
        
        interactor.output = self
        interactor.goalProvider = self
        setupLabels()
        setupDoneButton()
        setupTitleField()
        setupNoteField()
        setupStageTextField()
        setupAddStageButton()
        setupStagesTableView()
        setupKeyboardManager()
        stageCellActionsProvider.onDelete = { [unowned self] indexPath in
            self.interactor.removeStage(at: indexPath.row)
        }
    }
    
    override func refresh() {
        super.refresh()
        
        updateUI(goal: goal)
        reloadStages()
        
        if titleField.textView.text.isEmpty {
            titleField.becomeFirstResponder()
        }
    }
    
    override func setupAppearance() {
        super.setupAppearance()
        view.backgroundColor = AppTheme.current.colors.middlegroundColor
        contentView.backgroundColor = AppTheme.current.colors.middlegroundColor
        cardViews.forEach { $0.setupAppearance() }
        titleField.textView.textColor = AppTheme.current.colors.activeElementColor
        titleField.textView.font = AppTheme.current.fonts.bold(28)
        titleField.textView.keyboardAppearance = AppTheme.current.keyboardStyleForTheme
        noteField.textView.textColor = AppTheme.current.colors.activeElementColor
        noteField.textView.font = AppTheme.current.fonts.medium(17)
        noteField.textView.keyboardAppearance = AppTheme.current.keyboardStyleForTheme
        addStageButton.titleLabel?.font = AppTheme.current.fonts.medium(14)
        stageTextField.font = AppTheme.current.fonts.medium(17)
        stageTextField.textColor = AppTheme.current.colors.activeElementColor
        stageTextField.keyboardAppearance = AppTheme.current.keyboardStyleForTheme
        addStageButton.setTitleColor(.white, for: .normal)
        addStageButton.setTitleColor(AppTheme.current.colors.middlegroundColor, for: .disabled)
        addStageButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        addStageButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.inactiveElementColor), for: .disabled)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !UserProperty.isGoalCreationOnboardingShown.bool() {
            UserProperty.isGoalCreationOnboardingShown.setBool(true)
            
            let onboardingController = GoalCreationOnboardingViewController()
            
            present(onboardingController, animated: true, completion: nil)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.updateHintPopover()
    }
    
    @IBAction private func onAddStage() {
        guard let title = stageTextField.text?.trimmed, !title.isEmpty else { return }
        interactor.addStage(with: title)
        stageTextField.text = nil
        addStageButton.isEnabled = false
    }
    
    @IBAction private func onClose() {
        dismiss(animated: true, completion: nil)
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
        stagesHintButton.isSelected = false
        hideHintPopover()
    }
    
    @IBAction private func onTapToHint(_ button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            self.showFullWidthHintPopover("stages_hint".localized, button: button)
        } else {
            self.hideHintPopover()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath = keyPath, keyPath == "contentSize" {
            if let contentSizeValue = change?[.newKey] as? NSValue {
                let contentHeight = max(0, contentSizeValue.cgSizeValue.height)
                updateStagesTableViewHeight(contentHeight)
            }
        }
    }
    
    deinit {
        stagesTableView.removeObserver(self, forKeyPath: "contentSize")
    }
    
}

extension TargetCreationViewController: TargetCreationInteractorOutput {
    
    func reloadStages() {
        stagesTableView.reloadData()
    }
    
    func batchReloadStages(insertions: [Int] = [], deletions: [Int] = [], updates: [Int] = []) {
        UIView.performWithoutAnimation {
            self.stagesTableView.beginUpdates()
            
            deletions.forEach { index in
                self.stagesTableView.deleteRows(at: [IndexPath(row: index, section: 0)],
                                          with: .none)
            }
            
            insertions.forEach { index in
                self.stagesTableView.insertRows(at: [IndexPath(row: index, section: 0)],
                                          with: .none)
            }
            
            updates.forEach { index in
                self.stagesTableView.reloadRows(at: [IndexPath(row: index, section: 0)],
                                          with: .none)
            }
            
            self.stagesTableView.endUpdates()
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

extension TargetCreationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interactor.stagesCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StageCell", for: indexPath) as! StageCell
        
        if let stage = interactor.stage(at: indexPath.row) {
            cell.title = stage.title
            cell.stageNumber = indexPath.row + 1
            
            cell.onChangeTitle = { [unowned self, unowned cell] title in
                guard let actualIndexPath = tableView.indexPath(for: cell) else { return }
                self.interactor.updateStage(at: actualIndexPath.row, newTitle: title)
            }
            cell.onChangeHeight = { [unowned self] height in
                UIView.performWithoutAnimation {
                    self.stagesTableView.beginUpdates()
                    self.stagesTableView.endUpdates()
                }
            }
            
            cell.delegate = stageCellActionsProvider
            
            cell.applyAppearance()
        }
        
        return cell
    }
    
}

extension TargetCreationViewController: ReorderableTableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   reorderRowsFrom fromIndexPath: IndexPath,
                   to toIndexPath: IndexPath) {
        interactor.exchangeStages(at: (fromIndexPath.row, toIndexPath.row))
    }
    
    func tableView(_ tableView: UITableView, showDraggingView view: UIView, at indexPath: IndexPath) {
        view.backgroundColor = .white
    }
    
    func tableView(_ tableView: UITableView, hideDraggingView view: UIView, at indexPath: IndexPath) {
        view.backgroundColor = .clear
    }
    
}

extension TargetCreationViewController: UITextViewDelegate {
    
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

extension TargetCreationViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == contentScrollView || touch.view == contentView || touch.view is CardView
    }
    
}

extension TargetCreationViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hideHintPopover()
    }
    
}

private extension TargetCreationViewController {
 
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
    
    func setupLabels() {
        stagesTitleLabel.text = "stages".localized
        noteTitleLabel.text = "note".localized
        [stagesTitleLabel, noteTitleLabel].forEach { $0?.textColor = AppTheme.current.colors.inactiveElementColor }
    }
    
    func setupDoneButton() {
        headerView.rightButton?.setTitleColor(AppTheme.current.colors.inactiveElementColor, for: .disabled)
        headerView.rightButton?.setTitleColor(AppTheme.current.colors.mainElementColor, for: .normal)
    }
    
    func updateDoneButtonState() {
        headerView.rightButton?.isEnabled = !goal.title.isEmpty
    }
    
}

private extension TargetCreationViewController {
    
    func setupStagesTableView() {
        stagesTableView.estimatedRowHeight = 36
        stagesTableView.rowHeight = UITableView.automaticDimension
        stagesTableView.longPressReorderDelegate = self
        stagesTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    func updateStagesTableViewHeight(_ newHeight: CGFloat) {
        stagesTableViewHeightConstraint.constant = newHeight
        stagesTableViewTopConstraint.constant = newHeight == 0 ? 0 : 8
    }
    
}

private extension TargetCreationViewController {
    
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

private extension TargetCreationViewController {
    
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

private extension TargetCreationViewController {
    
    func setupStageTextField() {
        stageTextField.delegate = self
        stageTextField.attributedPlaceholder = NSAttributedString(string: "add_stage".localized,
                                                                  attributes: [.foregroundColor: AppTheme.current.colors.inactiveElementColor])
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onStageTextChange),
                                               name: UITextField.textDidChangeNotification,
                                               object: stageTextField)
    }
    
    @objc private func onStageTextChange() {
        addStageButton.isEnabled = stageTextField.text?.trimmed.isEmpty == false
    }
    
    func setupAddStageButton() {
        addStageButton.isEnabled = false
        addStageButton.setTitle("add".localized, for: .normal)
    }
    
}

private extension TargetCreationViewController {
    
    func setupKeyboardManager() {
        keyboardManager.keyboardWillAppear = { [unowned self] frame, duration in
            UIView.animate(withDuration: duration) {
                let offset = self.calculateTargetScrollViewYOffset(keyboardFrame: frame)
                self.contentScrollViewOffset = offset
                self.contentScrollView.contentOffset.y += offset
            }
        }
        
        keyboardManager.keyboardWillDisappear = { [unowned self] frame, duration in
            UIView.animate(withDuration: duration) {
                self.contentScrollView.contentOffset.y -= self.contentScrollViewOffset
                self.contentScrollViewOffset = 0
            }
        }
    }
    
    func calculateTargetScrollViewYOffset(keyboardFrame: CGRect) -> CGFloat {
        guard let focusedView = contentView.currentFirstResponder() as? UIView else { return 0 }
        let convertedFocusedViewFrame = view.convert(focusedView.frame, from: focusedView)
        return max(0, convertedFocusedViewFrame.maxY - keyboardFrame.minY)
    }
    
}

extension TargetCreationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let title = textField.text?.trimmed, !title.isEmpty else { return false }
        interactor.addStage(with: title)
        textField.text = nil
        addStageButton.isEnabled = false
        return true
    }
    
}

import SwipeCellKit

final class StageCell: SwipeTableViewCell {
    
    var stageNumber: Int = 1 {
        didSet {
            stageNumberLabel.text = "#\(stageNumber)"
        }
    }
    
    var title: String {
        get { return titleView.textView.text }
        set { titleView.textView.text = newValue }
    }
    
    var onChangeTitle: ((String) -> Void)?
    var onChangeHeight: ((CGFloat) -> Void)?
    
    @IBOutlet private var titleView: GrowingTextView! {
        didSet {
            titleView.textView.delegate = self
            titleView.textView.isEditable = false
            titleView.textView.isSelectable = false
            titleView.clipsToBounds = true
            titleView.textView.textContainerInset.left = -4
            titleView.maxNumberOfLines = 5
            titleView.delegates.didChangeHeight = { [unowned self] height in
                self.onChangeHeight?(height)
            }
            addTapGestureRecognizer()
        }
    }
    
    @IBOutlet private var stageNumberLabel: UILabel! {
        didSet {
            stageNumberLabel.textColor = AppTheme.current.colors.inactiveElementColor
            stageNumberLabel.font = AppTheme.current.fonts.regular(15)
        }
    }
    
    private var titleBeforeEditing: String?
    
    func applyAppearance() {
        titleView.textView.textColor = AppTheme.current.colors.activeElementColor
        titleView.textView.keyboardAppearance = AppTheme.current.keyboardStyleForTheme
    }
    
}

extension StageCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        titleBeforeEditing = title
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        titleView.textView.isEditable = false
        titleView.textView.isSelectable = false
        if textView.text.isEmpty {
            title = titleBeforeEditing ?? ""
        }
        guard title != titleBeforeEditing else { return }
        onChangeTitle?(textView.attributedText.string)
    }
    
}

fileprivate extension StageCell {
    
    func addTapGestureRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(beginEditing))
        titleView.addGestureRecognizer(recognizer)
    }
    
    @objc func beginEditing() {
        self.hideSwipe(animated: true)
        titleView.textView.isEditable = true
        titleView.textView.isSelectable = true
        titleView.becomeFirstResponder()
    }
    
}
