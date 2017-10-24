//
//  ListEditorView.swift
//  Timmee
//
//  Created by Ilya Kharabet on 09.09.17.
//  Copyright © 2017 Mesterra. All rights reserved.
//

import UIKit

protocol ListEditorViewInput: class {
    func setListTitle(_ title: String)
    func setListNote(_ note: String)
    func setListIcon(_ icon: ListIcon)
    func setImportedTasksCount(_ count: Int)
    
    func getTitle() -> String
    func getNote() -> String
}

protocol ListEditorViewOutput: class {
    func doneButtonPressed()
    func closeButtonPressed()
    func importTasksButtonPressed()
    func listTitleEntered(_ title: String)
    func listNoteEntered(_ note: String)
    func listIconSelected(_ icon: ListIcon)
}

// TODO: Keyboard

final class ListEditorView: UIViewController {

    var output: ListEditorViewOutput!
    
    @IBOutlet fileprivate weak var contentView: BarView!
    @IBOutlet fileprivate weak var listTitleTextField: UITextField!
    @IBOutlet fileprivate weak var listNoteTextView: UITextView!
    @IBOutlet fileprivate weak var listIconsView: UICollectionView!
    @IBOutlet fileprivate weak var importTasksButton: UIButton!
    @IBOutlet fileprivate weak var doneButton: UIButton!
    @IBOutlet fileprivate weak var closeButton: UIButton!
    
    @IBOutlet fileprivate var separators: [UIView]!
    
    @IBOutlet fileprivate weak var bottomConstraint: NSLayoutConstraint!
    
    
    @IBAction fileprivate func didPressImportTasksButton() {
        output.importTasksButtonPressed()
    }
    
    @IBAction fileprivate func didPressDoneButton() {
        output.doneButtonPressed()
    }
    
    @IBAction fileprivate func didPressCloseButton() {
        output.closeButtonPressed()
    }
    
    
    fileprivate var selectedListIcon: ListIcon?
    
    fileprivate let keyboardManager = KeyboardManager()
    fileprivate var shouldForceResignFirstResponder = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitioningDelegate = self
        setupKeyboardEventsHandler()
        setupTitleObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        contentView.barColor = AppTheme.current.scheme.backgroundColor
        listTitleTextField.textColor = AppTheme.current.scheme.specialColor
        listTitleTextField.tintColor = AppTheme.current.scheme.tintColor
        listNoteTextView.textColor = AppTheme.current.scheme.tintColor
        listNoteTextView.tintColor = AppTheme.current.scheme.tintColor
        closeButton.tintColor = AppTheme.current.scheme.backgroundColor
        doneButton.tintColor = AppTheme.current.scheme.greenColor
        importTasksButton.setTitleColor(AppTheme.current.scheme.blueColor, for: .normal)
        
        if !listTitleTextField.isFirstResponder {
            listTitleTextField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        shouldForceResignFirstResponder = true
        view.endEditing(true)
        shouldForceResignFirstResponder = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

extension ListEditorView: ListEditorViewInput {

    func setListTitle(_ title: String) {
        listTitleTextField.text = title
        
        setInterfaceEnabled(!title.isEmpty)
    }
    
    func setListNote(_ note: String) {
        listNoteTextView.text = note
    }
    
    func setListIcon(_ icon: ListIcon) {
        selectedListIcon = icon
        listIconsView.reloadData()
    }
    
    func setImportedTasksCount(_ count: Int) {
        if count == 0 {
            importTasksButton.setTitle("import_tasks".localized, for: .normal)
        } else {
            importTasksButton.setTitle("imported_n_tasks".localized(with: count),
                                       for: .normal)
        }
    }
    
    func getTitle() -> String {
        return listTitleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    func getNote() -> String {
        return listNoteTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

}

extension ListEditorView: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard !shouldForceResignFirstResponder else { return }
        guard let text = textField.text, !text.isEmpty else { return }
        output.listTitleEntered(text)
        
        textField.setNeedsLayout()
        textField.layoutIfNeeded()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard !shouldForceResignFirstResponder else { return true }
        return textField.text != nil && !textField.text!.isEmpty
    }

}

extension ListEditorView: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ListIcon.all.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListIconCell", for: indexPath) as! ListIconCell
        
        if let icon = ListIcon.all.item(at: indexPath.item) {
            cell.icon = icon
            cell.isSelected = icon == selectedListIcon
        }
        
        return cell
    }

}

extension ListEditorView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let icon = ListIcon.all.item(at: indexPath.item) {
            setListIcon(icon)
            output.listIconSelected(icon)
        }
    }

}

extension ListEditorView: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalPresentationTransition()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ModalDismissalTransition()
    }

}

fileprivate extension ListEditorView {

    var listTitle: String {
        return listTitleTextField.text ?? ""
    }
    
    var listNote: String {
        return listNoteTextView.text
    }

}

fileprivate extension ListEditorView {
    
    fileprivate func setupKeyboardEventsHandler() {
        keyboardManager.keyboardWillAppear = { (keyboardFrame, animationDuration) in
            self.bottomConstraint.constant = keyboardFrame.size.height
            
            UIView.animate(withDuration: animationDuration, animations: { [weak self] in
                self?.view.layoutIfNeeded()
            })
        }
        
        keyboardManager.keyboardWillDisappear = { (_, animationDuration) in
            self.bottomConstraint.constant = 0
            
            UIView.animate(withDuration: animationDuration, animations: { [weak self] in
                self?.view.layoutIfNeeded()
            })
        }
        keyboardManager.keyboardFrameDidChange = { (keyboardFrame, animationDuration) in
            self.bottomConstraint.constant = keyboardFrame.size.height
            
            UIView.animate(withDuration: animationDuration, animations: { [weak self] in
                self?.view.layoutIfNeeded()
            })
        }
    }
    
}

fileprivate extension ListEditorView {

    func setupTitleObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(listTitleDidChange),
                                               name: .UITextFieldTextDidChange,
                                               object: nil)
    }
    
    @objc func listTitleDidChange(notification: Notification) {
        if let text = listTitleTextField.text, !text.isEmpty {
            setInterfaceEnabled(true)
        } else {
            setInterfaceEnabled(false)
        }
    }
    
    func setInterfaceEnabled(_ isEnabled: Bool) {
        doneButton.isEnabled = isEnabled
        
        separators.forEach { separator in
            UIView.animate(withDuration: 0.2, animations: {
                separator.isHidden = !isEnabled
            })
        }
        let viewsToHide: [UIView] = [listNoteTextView, listIconsView, importTasksButton]
        viewsToHide.forEach { view in
            UIView.animate(withDuration: 0.2, animations: {
                view.isUserInteractionEnabled = isEnabled
                view.alpha = isEnabled ? 1 : 0
            })
        }
    }

}
