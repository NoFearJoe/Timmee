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
    
    private var listIconsView: ListIconsViewInput! {
        didSet {
            listIconsView.output = self
        }
    }
    @IBOutlet private var listIconsViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private var contentView: BarView!
    @IBOutlet private var listTitleTextField: GrowingTextView!
    @IBOutlet private var listNoteTextView: GrowingTextView!
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
    
    private var shouldForceResignFirstResponder = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitioningDelegate = self
        setupTitleObserver()
        
        setInterfaceEnabled(false)
        
        listTitleTextField.textView.delegate = self
        listTitleTextField.textView.font = UIFont.systemFont(ofSize: 20)
        listTitleTextField.textView.autocapitalizationType = .sentences
        listTitleTextField.textView.autocorrectionType = .yes
        listTitleTextField.minNumberOfLines = 1
        listTitleTextField.maxNumberOfLines = 3
        listTitleTextField.placeholderAttributedText = NSAttributedString(string: "new_list".localized,
                                                                          attributes: [.foregroundColor: AppTheme.current.secondaryTintColor,
                                                                                       .font: UIFont.systemFont(ofSize: 20)])
        
        listNoteTextView.textView.font = UIFont.systemFont(ofSize: 16)
        listNoteTextView.textView.autocapitalizationType = .sentences
        listNoteTextView.textView.autocorrectionType = .yes
        listNoteTextView.minNumberOfLines = 1
        listNoteTextView.maxNumberOfLines = 8
        listNoteTextView.placeholderAttributedText = NSAttributedString(string: "note".localized,
                                                                        attributes: [.foregroundColor: AppTheme.current.secondaryTintColor,
                                                                                     .font: UIFont.systemFont(ofSize: 16)])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = AppTheme.current.backgroundColor
        contentView.backgroundColor = AppTheme.current.middlegroundColor
        listTitleTextField.tintColor = AppTheme.current.tintColor
        listTitleTextField.textView.textColor = AppTheme.current.specialColor
        listNoteTextView.tintColor = AppTheme.current.tintColor
        listNoteTextView.textView.textColor = AppTheme.current.tintColor
        closeButton.tintColor = AppTheme.current.backgroundTintColor
        doneButton.tintColor = AppTheme.current.greenColor
        importTasksButton.setTitleColor(AppTheme.current.blueColor, for: .normal)
        headerLabels.forEach { label in
            label.text = label.text?.localized.uppercased()
            label.textColor = AppTheme.current.secondaryTintColor
        }
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EmbededListIconsView" {
            guard let listIconsView = segue.destination as? ListIconsViewInput else { return }
            self.listIconsView = listIconsView
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

}

extension ListEditorView: ListEditorViewInput {

    func setListTitle(_ title: String) {
        listTitleTextField.textView.text = title
        
        setInterfaceEnabled(!title.isEmpty)
    }
    
    func setListNote(_ note: String) {
        listNoteTextView.textView.text = note
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
        return listTitleTextField.textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func getNote() -> String {
        return listNoteTextView.textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
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

extension ListEditorView: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard !shouldForceResignFirstResponder else { return }
        guard let text = textView.text, !text.trimmed.isEmpty else { return }
        output.listTitleEntered(text)
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

    func setupTitleObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(listTitleDidChange),
                                               name: .UITextViewTextDidChange,
                                               object: nil)
    }
    
    @objc func listTitleDidChange() {
        if let text = listTitleTextField.textView.text, !text.trimmed.isEmpty {
            setInterfaceEnabled(true)
        } else {
            setInterfaceEnabled(false)
        }
    }
    
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
