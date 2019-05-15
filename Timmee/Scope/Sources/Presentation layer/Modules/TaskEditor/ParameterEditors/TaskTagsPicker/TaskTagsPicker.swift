//
//  TaskTagsPicker.swift
//  Timmee
//
//  Created by Ilya Kharabet on 22.10.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit
import SwipeCellKit

protocol TaskTagsPickerInput: class {
    func setSelectedTags(_ tags: [Tag])
}

protocol TaskTagsPickerOutput: class {
    func tagSelected(_ tag: Tag)
    func tagDeselected(_ tag: Tag)
    func tagRemoved(_ tag: Tag)
    func tagUpdated(_ tag: Tag)
}

final class TaskTagsPicker: UIViewController {
    
    weak var output: TaskTagsPickerOutput?
    weak var container: TaskParameterEditorOutput?
    
    @IBOutlet fileprivate var addTagView: AddTagView!
    @IBOutlet fileprivate var tagsView: UITableView!
    
    fileprivate lazy var placeholder: PlaceholderView = PlaceholderView.loadedFromNib()
    
    fileprivate var selectedTags: [Tag] = []
    fileprivate var allTags: [Tag] = [] {
        didSet {
            allTags.sort(by: { $0.title < $1.title })
            
            allTags.isEmpty ? showNoTagsPlaceholder() : hideNoTagsPlaceholder()
        }
    }
    
    fileprivate let tagsService = ServicesAssembly.shared.tagsService
    
    fileprivate static let rowHeight: CGFloat = 36
    
    fileprivate let cellActionsProvider = SubtaskCellActionsProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPlaceholder()
        
        cellActionsProvider.onDelete = { [weak self] indexPath in
            if let tag = self?.allTags.item(at: indexPath.row) {
                self?.removeTag(tag)
            }
        }
        
        allTags = tagsService.fetchTags()
        tagsView.reloadData()
        
        addTagView.placeholder = "input_tag".localized
        addTagView.backgroundColor = AppTheme.current.panelColor
        addTagView.color = addTagView.colors.first!
        addTagView.onCreateTag = { [weak self] title, color in
            let tagID = RandomStringGenerator.randomString(length: 16)
            let tag = Tag(id: tagID, title: title, color: color)
            self?.addNewTag(tag)
        }
    }
    
}

extension TaskTagsPicker: TaskTagsPickerInput {
    
    func setSelectedTags(_ tags: [Tag]) {
        selectedTags = tags
        tagsView.reloadData()
    }
    
}

extension TaskTagsPicker: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagTableCell",
                                                 for: indexPath) as! TagTableCell
        
        if let tag = allTags.item(at: indexPath.row) {
            cell.title = tag.title
            cell.color = tag.color
            cell.isPicked = selectedTags.contains(tag)
            cell.delegate = cellActionsProvider
        }
        
        return cell
    }
    
}

extension TaskTagsPicker: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectTag(at: indexPath.row)
        UIView.performWithoutAnimation {
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TaskTagsPicker.rowHeight
    }
    
}

extension TaskTagsPicker: TaskParameterEditorInput {
    
    var requiredHeight: CGFloat {
        return CGFloat(10) * TaskTagsPicker.rowHeight + 96
    }
}

fileprivate extension TaskTagsPicker {
    
    func addNewTag(_ tag: Tag) {
        allTags.append(tag)
        
        tagsService.createOrUpdateTag(tag, completion: nil)
        
        if let index = allTags.index(of: tag) {
            tagsView.insertRows(at: [IndexPath(row: index, section: 0)], with: .none)
        } else {
            tagsView.reloadData()
        }
        
        addTagView.hideTagColors()
    }
    
    func removeTag(_ tag: Tag) {
        selectedTags.remove(object: tag)
        allTags.remove(object: tag)
        
        output?.tagRemoved(tag)
        tagsService.removeTag(tag, completion: nil)
        
        if let index = allTags.index(of: tag) {
            tagsView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .none)
        } else {
            tagsView.reloadData()
        }
    }
    
    func updateTag(_ tag: Tag) {
        // ???
        allTags.sort(by: { $0.title < $1.title })
        
        output?.tagUpdated(tag)
        tagsService.createOrUpdateTag(tag, completion: nil)
        
        if let index = allTags.index(of: tag) {
            tagsView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        } else {
            tagsView.reloadData()
        }
    }
    
    func selectTag(at index: Int) {
        if let tag = allTags.item(at: index) {
            if selectedTags.contains(tag) {
                selectedTags.remove(object: tag)
                output?.tagDeselected(tag)
            } else {
                selectedTags.append(tag)
                output?.tagSelected(tag)
            }
        }
    }
    
    
    func showNoTagsPlaceholder() {
        guard placeholder.isHidden else { return }
        self.placeholder.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {
            self.placeholder.alpha = 1
        }, completion: { _ in
            self.placeholder.isHidden = false
        })
    }
    
    func hideNoTagsPlaceholder() {
        guard !placeholder.isHidden else { return }
        self.placeholder.alpha = 1
        UIView.animate(withDuration: 0.2, animations: {
            self.placeholder.alpha = 0
        }, completion: { _ in
            self.placeholder.isHidden = true
        })
    }
    
    func setupPlaceholder() {
        placeholder.setup(into: view)
        placeholder.icon = #imageLiteral(resourceName: "no_tasks")
        placeholder.title = "no_tags".localized
        placeholder.subtitle = "no_tags_hint".localized
        placeholder.isHidden = true
    }
    
}


final class TagTableCell: SwipeTableViewCell {
    
    @IBOutlet fileprivate var titleLabel: UILabel!
    @IBOutlet fileprivate var colorView: UIView!
    @IBOutlet fileprivate var checkBox: CheckBox!
    
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    var color: UIColor? {
        get { return colorView.backgroundColor }
        set { colorView.backgroundColor = newValue }
    }
    
    var isPicked: Bool = false {
        didSet {
            checkBox.isChecked = isPicked
        }
    }
    
}

final class AddTagView: BarView {
    
    @IBOutlet private var colorView: UIView! {
        didSet {
            addTapGestureRecognizer(to: colorView)
        }
    }
    
    @IBOutlet private var textField: UITextField! {
        didSet {
            textField.addTarget(self, action: #selector(onTextChange(_:)), for: .editingChanged)
        }
    }
    
    @IBOutlet private var addButton: UIButton! {
        didSet {
            addButton.adjustsImageWhenHighlighted = false
            addButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.blueColor), for: .normal)
            addButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.secondaryTintColor), for: .disabled)
            addButton.setBackgroundImage(UIImage.plain(color: AppTheme.current.secondaryTintColor), for: .selected)
            addButton.tintColor = .white
            addButton.layer.cornerRadius = AppTheme.current.cornerRadius
            addButton.isEnabled = false
        }
    }
    
    @IBAction private func onTapToAddButton() {
        createTag()
    }
    
    var placeholder: String = "" {
        didSet {
            textField.attributedPlaceholder = placeholder.asForegroundPlaceholder
        }
    }
    
    var color: UIColor = AppTheme.current.tagColors.first! {
        didSet {
            colorView.backgroundColor = color
        }
    }
    
    var colors: [UIColor] = AppTheme.current.tagColors
    
    var onCreateTag: ((String, UIColor) -> Void)?
    
    @IBOutlet private weak var colorPicker: ColorPicker? {
        didSet {
            colorPicker?.backgroundColor = AppTheme.current.panelColor
            colorPicker?.colors = colors
            colorPicker?.selectedColorIndex = colors.index(of: color) ?? -1
            colorPicker?.onSelectColor = { [weak self] color in
                self?.color = color
            }
        }
    }
    @IBOutlet private weak var colorPickerHeightConstraint: NSLayoutConstraint!
    
    private func addTapGestureRecognizer(to view: UIView) {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapToColor))
        view.addGestureRecognizer(recognizer)
    }
    
    @objc private func tapToColor() {
        guard let colorPicker = colorPicker else { return }
        colorPicker.selectedColorIndex = colors.index(of: color) ?? -1
        
        colorPickerHeightConstraint.constant == 0 ? showTagColors() : hideTagColors()
    }
    
    func showTagColors() {
        colorPickerHeightConstraint.constant = 52
        UIView.animate(withDuration: 0.2) {
            self.superview?.layoutIfNeeded()
        }
    }
    
    func hideTagColors() {
        colorPickerHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.2) {
            self.superview?.layoutIfNeeded()
        }
    }
    
}

extension AddTagView: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        createTag()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        createTag()
        return true
    }
    
    @objc private func onTextChange(_ textField: UITextField) {
        addButton.isEnabled = !(textField.text == nil || textField.text!.isEmpty)
    }
    
}

private extension AddTagView {
    func createTag() {
        if let text = textField.text, !text.isEmpty {
            onCreateTag?(text, color)
            textField.text = nil
        }
    }
}
