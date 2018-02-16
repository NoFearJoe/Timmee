//
//  ListEditorTextFieldController.swift
//  Timmee
//
//  Created by Илья Харабет on 15.02.2018.
//  Copyright © 2018 Mesterra. All rights reserved.
//

import UIKit

// MARK: - Input
protocol ListEditorTextFieldInput: class {
    var text: String { get }
    
    func setOutput(_ output: ListEditorTextFieldOutput)
    
    func setup(fontSize: CGFloat, maxLines: Int, placeholder: String, textColor: UIColor)
    func setText(_ text: String)
    func setFocused()
}

// MARK: - Output
protocol ListEditorTextFieldOutput: class {
    func listEditorTextField(_ textField: ListEditorTextFieldInput, didChangeText text: String)
    func listEditorTextField(_ textField: ListEditorTextFieldInput, didEndEditing text: String)
}

// MARK: - Class
final class ListEditorTextFieldController: UIViewController {
    
    weak var output: ListEditorTextFieldOutput?
    
    @IBOutlet private var textView: GrowingTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        setupTextObserver()
        
        textView.textView.delegate = self
        textView.textView.autocapitalizationType = .sentences
        textView.textView.autocorrectionType = .yes
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.tintColor = AppTheme.current.tintColor
    }
    
}

// MARK: - ListEditorTextFieldInput
extension ListEditorTextFieldController: ListEditorTextFieldInput {
    
    var text: String {
        return textView.textView.text.trimmed
    }
    
    func setOutput(_ output: ListEditorTextFieldOutput) {
        self.output = output
    }
    
    func setup(fontSize: CGFloat, maxLines: Int, placeholder: String, textColor: UIColor) {
        textView.textView.textColor = textColor
        textView.textView.font = UIFont.systemFont(ofSize: fontSize)
        textView.minNumberOfLines = 1
        textView.maxNumberOfLines = maxLines
        textView.placeholderAttributedText = NSAttributedString(string: placeholder,
                                                                attributes: [.foregroundColor: AppTheme.current.secondaryTintColor,
                                                                             .font: UIFont.systemFont(ofSize: fontSize)])
    }
    
    func setText(_ text: String) {
        textView.textView.text = text
        output?.listEditorTextField(self, didChangeText: text)
    }
    
    func setFocused() {
        guard !textView.isFirstResponder else { return }
        textView.becomeFirstResponder()
    }
    
}

// MARK: - UITextViewDelegate
extension ListEditorTextFieldController: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let text = textView.text, !text.trimmed.isEmpty else { return }
        output?.listEditorTextField(self, didEndEditing: text)
    }
    
}

// MARK: - Private methdos
private extension ListEditorTextFieldController {
    
    func setupTextObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChange),
                                               name: .UITextViewTextDidChange,
                                               object: nil)
    }
    
    @objc func textDidChange() {
        let text = textView.textView.text ?? ""
        output?.listEditorTextField(self, didChangeText: text)
    }
    
}
