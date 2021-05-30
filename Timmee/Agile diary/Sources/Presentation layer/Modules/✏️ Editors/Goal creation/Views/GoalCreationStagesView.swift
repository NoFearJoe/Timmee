//
//  GoalCreationStagesView.swift
//  Agile diary
//
//  Created by Илья Харабет on 31/12/2019.
//  Copyright © 2019 Mesterra. All rights reserved.
//

import UIKit
import UIComponents

final class GoalCreationStagesView: UIView {
    
    var onAddStage: ((String) -> Void)?
    var onReorder: ((_ from: IndexPath, _ to: IndexPath) -> Void)?
    
    private let addStageContainer = UIView()
    
    let stageTextField = UITextField()
    let addStageButton = UIButton()
    let stagesTableView = AutosizingReorderableTableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "contentSize" else { return }
        guard let contentSize = change?[.newKey] as? CGSize else { return }
        
        stagesTableView.contentInset.top = contentSize.height > 0 ? 8 : 0
    }
    
    deinit {
        stagesTableView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    func setupAppearance() {
        stageTextField.font = AppTheme.current.fonts.medium(17)
        stageTextField.textColor = AppTheme.current.colors.activeElementColor
        stageTextField.keyboardAppearance = AppTheme.current.keyboardStyleForTheme
        
        addStageButton.layer.cornerRadius = 8
        addStageButton.clipsToBounds = true
        addStageButton.titleLabel?.font = AppTheme.current.fonts.medium(14)
        addStageButton.adjustsImageWhenDisabled = false
        addStageButton.backgroundColor = nil
        addStageButton.setTitleColor(.white, for: .normal)
        addStageButton.setTitleColor(UIColor.white.withAlphaComponent(0.85), for: .disabled)
        addStageButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor), for: .normal)
        addStageButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.colors.mainElementColor.withAlphaComponent(0.6)), for: .disabled)
        
        stagesTableView.separatorStyle = .none
        stagesTableView.backgroundColor = .clear
    }
    
}

private extension GoalCreationStagesView {
    
    func setupViews() {
        addSubview(addStageContainer)
        addStageContainer.addSubview(stageTextField)
        addStageContainer.addSubview(addStageButton)
        addSubview(stagesTableView)
        
        setupStagesTableView()
        setupStageTextField()
        setupAddStageButton()
    }
    
    func setupStagesTableView() {
        stagesTableView.backgroundColor = .clear
        stagesTableView.estimatedRowHeight = 36
        stagesTableView.rowHeight = UITableView.automaticDimension
        stagesTableView.showsVerticalScrollIndicator = false
        stagesTableView.tableFooterView = UIView()
        stagesTableView.longPressReorderDelegate = self
        
        if #available(iOS 11.0, *) {
            stagesTableView.contentInsetAdjustmentBehavior = .never
        }
        
        stagesTableView.register(
            GoalCreationStageCell.self,
            forCellReuseIdentifier: GoalCreationStageCell.reuseIdentifier
        )
        
        stagesTableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    
    func setupStageTextField() {
        stageTextField.delegate = self
        
        stageTextField.clipsToBounds = true
        
        stageTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
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
        addStageButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        addStageButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        addStageButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        addStageButton.addTarget(self, action: #selector(addStage), for: .touchUpInside)
    }
    
    func setupLayout() {
        addStageContainer.height(28)
        [addStageContainer.leading(), addStageContainer.trailing(), addStageContainer.top()].toSuperview()
        addStageContainer.bottomToTop().to(stagesTableView, addTo: self)
        
        [stageTextField.leading(), stageTextField.centerY()].toSuperview()
        stageTextField.trailingAnchor.constraint(lessThanOrEqualTo: addStageButton.leadingAnchor, constant: -4).isActive = true
        
        [addStageButton.bottom(), addStageButton.trailing(), addStageButton.top()].toSuperview()
        
        [stagesTableView.leading(), stagesTableView.trailing(), stagesTableView.bottom()].toSuperview()
    }
    
    @objc
    @discardableResult
    func addStage() -> Bool {
        guard let title = stageTextField.text?.trimmed, !title.isEmpty else { return false }
        
        onAddStage?(title)
        
        stageTextField.text = nil
        addStageButton.isEnabled = false
        
        return true
    }
    
}

extension GoalCreationStagesView: ReorderableTableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   reorderRowsFrom fromIndexPath: IndexPath,
                   to toIndexPath: IndexPath) {
        onReorder?(fromIndexPath, toIndexPath)
    }
    
    func tableView(_ tableView: UITableView, showDraggingView view: UIView, at indexPath: IndexPath) {
        view.backgroundColor = .white
    }
    
    func tableView(_ tableView: UITableView, hideDraggingView view: UIView, at indexPath: IndexPath) {
        view.backgroundColor = .clear
    }
    
}

extension GoalCreationStagesView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return addStage()
    }
    
}
