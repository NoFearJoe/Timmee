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

final class ListEditorView: UIViewController {

    var output: ListEditorViewOutput!
    
    private var listIconsView: ListIconsViewInput!
    @IBOutlet private var listIconsViewHeightConstraint: NSLayoutConstraint!
    
    private var listTitleView: ListEditorTextFieldInput!
    private var listNoteView: ListEditorTextFieldInput!
    
    @IBOutlet private var contentView: BarView!
    @IBOutlet private var importTasksButton: UIButton!
    @IBOutlet private var doneButton: UIButton!
    @IBOutlet private var closeButton: UIButton!
    
    @IBOutlet private var headerLabels: [UILabel]!
    @IBOutlet private var initiallyHiddenViews: [UIView]!
    
    @IBAction private func didPressImportTasksButton() {
        output.importTasksButtonPressed()
    }
    
    @IBAction private func didPressDoneButton() {
        output.doneButtonPressed()
    }
    
    @IBAction private func didPressCloseButton() {
        output.closeButtonPressed()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitioningDelegate = self
        
        setInterfaceEnabled(false)
        
        listTitleView.setup(fontSize: 20, maxLines: 3, placeholder: "new_list".localized, textColor: AppTheme.current.specialColor)
        listNoteView.setup(fontSize: 16, maxLines: 8, placeholder: "note".localized, textColor: AppTheme.current.tintColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = AppTheme.current.backgroundColor
        contentView.backgroundColor = AppTheme.current.middlegroundColor
        closeButton.tintColor = AppTheme.current.backgroundTintColor
        doneButton.tintColor = AppTheme.current.greenColor
        importTasksButton.setTitleColor(AppTheme.current.blueColor, for: .normal)
        headerLabels.forEach { label in
            label.text = label.text?.localized.uppercased()
            label.textColor = AppTheme.current.secondaryTintColor
        }
        
        if getTitle().isEmpty {
            listTitleView.setFocused()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbededListIconsView" {
            guard let listIconsView = segue.destination as? ListIconsViewInput else { return }
            self.listIconsView = listIconsView
            self.listIconsView.setOutput(self)
        } else if segue.identifier == "EmbedTitleTextView" {
            guard let listTitleView = segue.destination as? ListEditorTextFieldInput else { return }
            self.listTitleView = listTitleView
            self.listTitleView.setOutput(self)
        } else if segue.identifier == "EmbedNoteTextView" {
            guard let listNoteView = segue.destination as? ListEditorTextFieldInput else { return }
            self.listNoteView = listNoteView
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

}

extension ListEditorView: ListEditorViewInput {

    func setListTitle(_ title: String) {
        listTitleView.setText(title)
    }
    
    func setListNote(_ note: String) {
        listNoteView.setText(note)
    }
    
    func setListIcon(_ icon: ListIcon) {
        listIconsView.setListIcon(icon)
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
        return listTitleView.text
    }
    
    func getNote() -> String {
        return listNoteView.text
    }

}

extension ListEditorView: ListEditorTextFieldOutput {
    
    func listEditorTextField(_ textField: ListEditorTextFieldInput, didChangeText text: String) {
        setInterfaceEnabled(!text.trimmed.isEmpty)
    }
    
    func listEditorTextField(_ textField: ListEditorTextFieldInput, didEndEditing text: String) {
        output.listTitleEntered(text)
    }
    
}

extension ListEditorView: ListIconsViewOutput {
    
    func didSelectListIcon(_ icon: ListIcon) {
        output.listIconSelected(icon)
    }
    
    func didChangeContentHeight(_ height: CGFloat) {
        listIconsViewHeightConstraint.constant = height
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

private extension ListEditorView {
    
    func setInterfaceEnabled(_ isEnabled: Bool) {
        doneButton.isEnabled = isEnabled
        
        initiallyHiddenViews.forEach { view in
            UIView.animate(withDuration: 0.2, animations: {
                view.isUserInteractionEnabled = isEnabled
                view.alpha = isEnabled ? 1 : 0
            })
        }
    }

}
