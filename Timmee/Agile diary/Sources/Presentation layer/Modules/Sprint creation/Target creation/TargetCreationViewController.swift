//
//  TargetCreationViewController.swift
//  Agile diary
//
//  Created by i.kharabet on 15.08.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

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

final class TargetCreationViewController: UIViewController, TargetProvider {
    
    @IBOutlet private var headerView: LargeHeaderView!
    @IBOutlet private var titleField: GrowingTextView!
    @IBOutlet private var stageTextField: UITextField!
    @IBOutlet private var stagesTableView: ReorderableTableView!
    @IBOutlet private var stagesTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var stagesTableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private var importancySwitcher: Switcher!
    
    private var selectedImportancy = TargetImportancy.normal
    
    private let interactor = TargetCreationInteractor()
    
    private let stageCellActionsProvider = StageCellActionsProvider()
    
    var target: Task!
    
    func setTarget(_ target: Task?) {
        self.target = target?.copy ?? interactor.createTarget()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interactor.output = self
        interactor.targetProvider = self
        setupTitleField()
        setupStageTextField()
        setupStagesTableView()
        setupImportancySwitcher()
        stageCellActionsProvider.onDelete = { [unowned self] indexPath in
            self.interactor.removeStage(at: indexPath.row)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction private func onClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func onDone() {
        // Save
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func endEditing() {
        view.endEditing(true)
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
        batchReloadStages(deletions: indexes)
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
            
            cell.onChangeTitle = { [unowned self, unowned cell] title in
                guard let actualIndexPath = tableView.indexPath(for: cell) else { return }
                self.interactor.updateStage(at: actualIndexPath.row, newTitle: title)
            }
            
            cell.delegate = stageCellActionsProvider
        }
        
        return cell
    }
    
}

extension TargetCreationViewController: ReorderableTableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   reorderRowsFrom fromIndexPath: IndexPath,
                   to toIndexPath: IndexPath) {
//        output.exchangeSubtasks(at: (fromIndexPath.row, toIndexPath.row))
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
    
}

private extension TargetCreationViewController {
    
    func setupStagesTableView() {
        stagesTableView.estimatedRowHeight = 36
        stagesTableView.rowHeight = UITableViewAutomaticDimension
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
        titleField.textView.textContainerInset = .zero
        titleField.textView.font = UIFont.avenirNextMedium(24)
        titleField.maxNumberOfLines = 5
        titleField.showsVerticalScrollIndicator = false
        titleField.placeholderAttributedText
            = NSAttributedString(string: "target_title_placeholder".localized,
                                 attributes: [.font: UIFont.avenirNextMedium(24),
                                              .foregroundColor: UIColor(rgba: "dddddd")])
        
        setupTitleObserver()
    }
    
    func setupTitleObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(targetTitleDidChange),
                                               name: .UITextViewTextDidChange,
                                               object: titleField.textView)
    }
    
    @objc func targetTitleDidChange(notification: Notification) {
        let text = getTargetTitle()
        target.title = text
    }
    
    func getTargetTitle() -> String {
        return titleField.textView.text.trimmed
    }
    
}

private extension TargetCreationViewController {
    
    func setupStageTextField() {
        stageTextField.delegate = self
        stageTextField.textColor = UIColor(rgba: "444444")
        stageTextField.attributedPlaceholder = NSAttributedString(string: "add_stage".localized,
                                                                  attributes: [.foregroundColor: UIColor(rgba: "dddddd")])
    }
    
}

extension TargetCreationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let title = textField.text?.trimmed, !title.isEmpty else { return false }
        interactor.addStage(with: title)
        textField.text = nil
        return true
    }
    
}

private extension TargetCreationViewController {

    func setupImportancySwitcher() {
        importancySwitcher.items = [TargetImportancy.low.title, TargetImportancy.normal.title, TargetImportancy.high.title]
        importancySwitcher.selectedItemIndex = selectedImportancy.rawValue
        importancySwitcher.addTarget(self, action: #selector(onSwitchImportancy), for: .touchUpInside)
    }
    
    @objc func onSwitchImportancy() {
        selectedImportancy = TargetImportancy(rawValue: importancySwitcher.selectedItemIndex) ?? .normal
    }

}

import SwipeCellKit

final class StageCell: SwipeTableViewCell {
    
    var title: String {
        get { return titleView.textView.text }
        set { titleView.textView.text = newValue }
    }
    
    var onChangeTitle: ((String) -> Void)?
    
    @IBOutlet private var titleView: GrowingTextView! {
        didSet {
            titleView.textView.delegate = self
            titleView.textView.isEditable = false
            titleView.textView.isSelectable = false
            addTapGestureRecognizer()
        }
    }
    
    private var titleBeforeEditing: String?
    
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

final class StageCellActionsProvider {
    
    var onDelete: ((IndexPath) -> Void)?
    
    static var backgroundColor: UIColor {
        return .clear
    }
    
    fileprivate lazy var swipeTableOptions: SwipeTableOptions = {
        var options = SwipeTableOptions()
        options.expansionStyle = nil
        options.transitionStyle = SwipeTransitionStyle.drag
        options.backgroundColor = StageCellActionsProvider.backgroundColor
        return options
    }()
    
    fileprivate lazy var swipeDeleteAction: SwipeAction = {
        let deleteAction = SwipeAction(style: .default,
                                       title: "delete".localized,
                                       handler:
            { [weak self] (action, indexPath) in
                self?.onDelete?(indexPath)
                action.fulfill(with: .delete)
        })
        deleteAction.image = #imageLiteral(resourceName: "trash")
        deleteAction.textColor = UIColor.red
        deleteAction.title = nil
        deleteAction.backgroundColor = StageCellActionsProvider.backgroundColor
        deleteAction.transitionDelegate = nil
        return deleteAction
    }()
    
}

extension StageCellActionsProvider: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        switch orientation {
        case .left: return nil
        case .right: return [swipeDeleteAction]
        }
    }
    
    func tableView(_ tableView: UITableView,
                   editActionsOptionsForRowAt indexPath: IndexPath,
                   for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        return swipeTableOptions
    }
    
}
